import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
// ignore: depend_on_referenced_packages
import 'package:light/light.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/config/app_config.dart';
import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/utils/geo_utils.dart';
import 'package:nousdeux/domain/entities/location_sharing_entity.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/presentation/providers/location_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';

/// Position tab: Mapbox (Sensor-based Dark Mode), circular avatars, compact UI.
class PositionScreen extends ConsumerStatefulWidget {
  const PositionScreen({super.key});

  @override
  ConsumerState<PositionScreen> createState() => _PositionScreenState();
}

class _PositionScreenState extends ConsumerState<PositionScreen> {
  // Realtime
  RealtimeChannel? _locationChannel;
  String? _subscribedCoupleId;

  // Mapbox
  static bool get _useMapbox =>
      AppConfig.isMapboxConfigured &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  mapbox.MapboxMap? _mapboxMap;
  mapbox.PointAnnotationManager? _pointAnnotationManager;

  // --- Ambient Light & Style Logic ---
  static const int _luxBufferSize = 10;
  final List<int> _luxBuffer = [];

  Light? _lightSensor;
  StreamSubscription<int>? _lightSubscription;

  // Start with a safe default (will be updated immediately in initState)
  String _currentMapStyle = mapbox.MapboxStyles.STANDARD;
  bool _isMapDark = false;

  // Assets & Caching
  Uint8List? _myCachedAvatarBytes;
  Uint8List? _partnerCachedAvatarBytes;
  String? _lastMyAvatarUrl;
  String? _lastMyName;
  String? _lastPartnerAvatarUrl;
  String? _lastPartnerName;

  @override
  void initState() {
    super.initState();
    _initAmbientMode();
  }

  // --- 1. Ambient Mode Logic (Sensor + Time fallback) ---

  void _initAmbientMode() {
    // A. Initial Check: Use Time of Day as a baseline
    _updateStyleBasedOnTime();

    // B. Try connecting to Light Sensor (for "Tunnel Mode")
    try {
      _lightSensor = Light();
      _lightSubscription = _lightSensor?.lightSensorStream.listen(_onLightData);
    } catch (e) {
      debugPrint('Light sensor not available: $e');
    }
  }

  /// Called whenever the lux value changes. Running average (no debounce).
  void _onLightData(int lux) {
    _luxBuffer.add(lux);
    if (_luxBuffer.length > _luxBufferSize) {
      _luxBuffer.removeAt(0);
    }
    if (_luxBuffer.isEmpty) return;
    final sum = _luxBuffer.reduce((a, b) => a + b);
    final avgLux = (sum / _luxBuffer.length).round();
    if (!mounted) return;
    _applyLuxLogic(avgLux);
  }

  void _applyLuxLogic(int lux) {
    String? targetStyle;

    if (lux < 30 && !_isMapDark) {
      targetStyle = mapbox.MapboxStyles.DARK;
    } else if (lux > 50 && _isMapDark) {
      targetStyle = mapbox.MapboxStyles.STANDARD;
    }

    if (targetStyle != null) {
      _switchMapStyle(targetStyle);
    }
  }

  void _updateStyleBasedOnTime() {
    // Fallback logic if sensor isn't ready or available
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 20; // Simplified night logic

    final targetStyle = isNight
        ? mapbox.MapboxStyles.DARK
        : mapbox.MapboxStyles.STANDARD;

    if (targetStyle != _currentMapStyle) {
      // Direct update for initial load
      setState(() {
        _currentMapStyle = targetStyle;
        _isMapDark = isNight;
      });
    }
  }

  /// Switches style dynamically and updates UI brightness
  Future<void> _switchMapStyle(String nextStyle) async {
    if (_currentMapStyle == nextStyle) return;
    if (!mounted) return;

    setState(() {
      _currentMapStyle = nextStyle;
      _isMapDark = (nextStyle == mapbox.MapboxStyles.DARK);
    });

    if (_mapboxMap != null) {
      try {
        await _mapboxMap!.loadStyleURI(nextStyle);
        if (!mounted) return;
        // Style reload often resets UI settings, re-apply them:
        await _applyMapSettings(_mapboxMap!);
        if (!mounted) return;

        // Refresh markers as style reload might clear canvas cache
        _myCachedAvatarBytes = null;
        _partnerCachedAvatarBytes = null;
      } catch (e) {
        debugPrint('Error switching map style: $e');
      }
    }
  }

  Future<void> _applyMapSettings(mapbox.MapboxMap map) async {
    try {
      await map.scaleBar.updateSettings(
        mapbox.ScaleBarSettings(enabled: false),
      );
    } catch (_) {}
  }

  // --- Realtime Logic ---

  void _subscribeToLocationRealtime(String? coupleId) {
    if (coupleId == null || coupleId == _subscribedCoupleId) return;
    _locationChannel?.unsubscribe();
    _subscribedCoupleId = coupleId;
    final client = Supabase.instance.client;
    _locationChannel = client
        .channel('location-couple-$coupleId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'location_sharing',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'couple_id',
            value: coupleId,
          ),
          callback: (_) {
            if (mounted) {
              ref.invalidate(myLocationSharingProvider);
              ref.invalidate(partnerLocationSharingProvider);
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    _locationChannel?.unsubscribe();
    ref.read(locationUpdateNotifierProvider.notifier).stop();
    super.dispose();
  }

  String _lang() => ref.read(myProfileProvider).valueOrNull?.language ?? 'fr';

  Future<void> _reload() async {
    final myLocation = await ref.read(myLocationSharingProvider.future);
    if (myLocation?.isSharing == true) {
      await ref
          .read(locationUpdateNotifierProvider.notifier)
          .pushCurrentPosition();
    }
    ref.invalidate(myLocationSharingProvider);
    ref.invalidate(partnerLocationSharingProvider);

    _myCachedAvatarBytes = null;
    _partnerCachedAvatarBytes = null;
    _lastMyAvatarUrl = null;
    _lastMyName = null;
    _lastPartnerAvatarUrl = null;
    _lastPartnerName = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_positionReloadDone(_lang())),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final partnerAsync = ref.watch(partnerProfileProvider);
    final coupleAsync = ref.watch(myCoupleProvider);
    final myLocationAsync = ref.watch(myLocationSharingProvider);
    final partnerLocationAsync = ref.watch(partnerLocationSharingProvider);

    coupleAsync.whenData((c) {
      if (c != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _subscribeToLocationRealtime(c.id);
        });
      }
    });

    ref.listen<AsyncValue<LocationSharingEntity?>>(myLocationSharingProvider, (
      prev,
      next,
    ) {
      if (!mounted) return;
      final isSharing = next.valueOrNull?.isSharing ?? false;
      if (isSharing) {
        ref.read(locationUpdateNotifierProvider.notifier).start();
      } else {
        ref.read(locationUpdateNotifierProvider.notifier).stop();
      }
    });

    final hasPartner = partnerAsync.valueOrNull != null;
    final myLocation = myLocationAsync.valueOrNull;
    final partnerLocation = partnerLocationAsync.valueOrNull;
    final myProfile = profileAsync.valueOrNull;
    final partnerProfile = partnerAsync.valueOrNull;

    if (!hasPartner) {
      return _buildScaffold(
        body: EmptyState(
          icon: Icons.location_off_outlined,
          message: _positionNoPartnerMessage(_lang()),
          secondary: _positionNoPartnerSecondary(_lang()),
        ),
        bottomWidget: FilledButton.icon(
          onPressed: () => context.push('/pairing'),
          icon: const Icon(Icons.person_add_outlined),
          label: Text(_positionInvitePartner(_lang())),
        ),
      );
    }

    final myPos = myLocation?.hasPosition == true
        ? LatLng(myLocation!.latitude!, myLocation.longitude!)
        : null;
    final partnerPos = partnerLocation?.hasPosition == true
        ? LatLng(partnerLocation!.latitude!, partnerLocation.longitude!)
        : null;
    final hasAnyPosition = myPos != null || partnerPos != null;

    if (!hasAnyPosition) {
      return _buildScaffold(
        body: EmptyState(
          icon: Icons.location_on_outlined,
          message: _positionEnableSharingMessage(_lang()),
          secondary: _positionEnableSharingSecondary(_lang()),
        ),
        bottomWidget: OutlinedButton.icon(
          onPressed: () => context.go('/main/settings'),
          icon: const Icon(Icons.settings_outlined),
          label: Text(_positionOpenSettings(_lang())),
        ),
      );
    }

    final distanceM = _distanceMeters(myPos, partnerPos);
    final isMerged =
        distanceM != null && distanceM < positionMergeThresholdMeters;

    if (_useMapbox && _mapboxMap != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateMapboxMarkers(
            myPos: myPos,
            partnerPos: partnerPos,
            isMerged: isMerged,
            myProfile: myProfile,
            partnerProfile: partnerProfile,
            context: context,
          );
        }
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Dynamic status bar: White text (Light) when map is Dark, and vice versa.
        systemOverlayStyle: _isMapDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _reload(),
              tooltip: _positionReloadTooltip(_lang()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_useMapbox)
            Positioned.fill(
              child: _buildMapboxMap(myPos: myPos, partnerPos: partnerPos),
            )
          else
            _MapboxOnlyPlaceholder(lang: _lang()),

          if (distanceM != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: _CompactDistanceChip(
                    distanceM: distanceM,
                    isMerged: isMerged,
                    lang: _lang(),
                  ),
                ),
              ),
            ),

          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: SafeArea(
              top: false,
              child: _FloatingNamesBar(
                myProfile: myProfile,
                partnerProfile: partnerProfile,
                myPos: myPos,
                partnerPos: partnerPos,
                onCenterMy: (_useMapbox && myPos != null)
                    ? () => _centerCameraOn(myPos)
                    : null,
                onCenterPartner: (_useMapbox && partnerPos != null)
                    ? () => _centerCameraOn(partnerPos)
                    : null,
                onFitBoth: (_useMapbox && myPos != null && partnerPos != null)
                    ? () => _fitBoth(myPos, partnerPos)
                    : null,
                lang: _lang(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Scaffold _buildScaffold({required Widget body, Widget? bottomWidget}) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_positionTitle(_lang())),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _reload(),
            tooltip: _positionReloadTooltip(_lang()),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: bottomWidget != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: bottomWidget,
              ),
            )
          : null,
    );
  }

  Widget _buildMapboxMap({
    required LatLng? myPos,
    required LatLng? partnerPos,
  }) {
    final startPos = myPos ?? partnerPos ?? const LatLng(48.8566, 2.3522);

    return mapbox.MapWidget(
      key: const ValueKey('mapbox-map-view'),
      styleUri: _currentMapStyle, // Controlled by Lux/Time logic
      cameraOptions: mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(startPos.longitude, startPos.latitude),
        ),
        zoom: 13.0,
      ),
      onMapCreated: (mapbox.MapboxMap map) async {
        _mapboxMap = map;
        await _applyMapSettings(map);

        _pointAnnotationManager = await map.annotations
            .createPointAnnotationManager();

        if (myPos != null && partnerPos != null) {
          _fitBoth(myPos, partnerPos, animated: false);
        } else if (myPos != null) {
          _centerCameraOn(myPos, zoom: 16.0, animated: false);
        }
      },
    );
  }

  void _centerCameraOn(LatLng pos, {double zoom = 16.5, bool animated = true}) {
    final camera = mapbox.CameraOptions(
      center: mapbox.Point(
        coordinates: mapbox.Position(pos.longitude, pos.latitude),
      ),
      zoom: zoom,
      pitch: 45,
      bearing: 0,
    );

    if (animated) {
      _mapboxMap?.flyTo(camera, mapbox.MapAnimationOptions(duration: 1200));
    } else {
      _mapboxMap?.setCamera(camera);
    }
  }

  Future<void> _fitBoth(LatLng a, LatLng b, {bool animated = true}) async {
    final dist = distanceMeters(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    if (dist < 50) {
      _centerCameraOn(a, zoom: 17.0, animated: animated);
      return;
    }

    final points = [
      mapbox.Point(coordinates: mapbox.Position(a.longitude, a.latitude)),
      mapbox.Point(coordinates: mapbox.Position(b.longitude, b.latitude)),
    ];

    final padding = mapbox.MbxEdgeInsets(
      top: 120.0,
      left: 50.0,
      bottom: 180.0,
      right: 50.0,
    );

    final baseCamera = mapbox.CameraOptions(pitch: 40.0, bearing: 0.0);

    try {
      final camera = await _mapboxMap?.cameraForCoordinatesPadding(
        points,
        baseCamera,
        padding,
        null,
        null,
      );

      if (camera != null) {
        if (animated) {
          await _mapboxMap?.flyTo(
            camera,
            mapbox.MapAnimationOptions(duration: 1500),
          );
        } else {
          await _mapboxMap?.setCamera(camera);
        }
      }
    } catch (e) {
      debugPrint('Error calculating camera: $e');
    }
  }

  // --- Marker Management & Image Generation ---

  Future<void> _updateMapboxMarkers({
    required LatLng? myPos,
    required LatLng? partnerPos,
    required bool isMerged,
    required ProfileEntity? myProfile,
    required ProfileEntity? partnerProfile,
    required BuildContext context,
  }) async {
    final manager = _pointAnnotationManager;
    if (manager == null) return;

    final myUrl = myProfile?.avatarUrl;
    final myName = myProfile?.username;

    if (_myCachedAvatarBytes == null ||
        _lastMyAvatarUrl != myUrl ||
        _lastMyName != myName) {
      _myCachedAvatarBytes = await _generateAvatar(
        myUrl,
        myName,
        context,
        true,
      );
      _lastMyAvatarUrl = myUrl;
      _lastMyName = myName;
    }

    final partnerUrl = partnerProfile?.avatarUrl;
    final partnerName = partnerProfile?.username;

    if (_partnerCachedAvatarBytes == null ||
        _lastPartnerAvatarUrl != partnerUrl ||
        _lastPartnerName != partnerName) {
      _partnerCachedAvatarBytes = await _generateAvatar(
        partnerUrl,
        partnerName,
        context,
        false,
      );
      _lastPartnerAvatarUrl = partnerUrl;
      _lastPartnerName = partnerName;
    }

    final myIcon = _myCachedAvatarBytes;
    final partnerIcon = _partnerCachedAvatarBytes;

    if (myIcon == null || partnerIcon == null) return;

    await manager.deleteAll();

    final options = <mapbox.PointAnnotationOptions>[];

    if (isMerged && myPos != null) {
      options.add(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(myPos.longitude, myPos.latitude),
          ),
          image: myIcon,
          iconSize: 1.5,
          iconOffset: [0, -10],
          symbolSortKey: 10,
        ),
      );
    } else {
      if (myPos != null) {
        options.add(
          mapbox.PointAnnotationOptions(
            geometry: mapbox.Point(
              coordinates: mapbox.Position(myPos.longitude, myPos.latitude),
            ),
            image: myIcon,
            iconSize: 1.2,
            iconOffset: [0, -5],
            symbolSortKey: 2,
          ),
        );
      }
      if (partnerPos != null) {
        options.add(
          mapbox.PointAnnotationOptions(
            geometry: mapbox.Point(
              coordinates: mapbox.Position(
                partnerPos.longitude,
                partnerPos.latitude,
              ),
            ),
            image: partnerIcon,
            iconSize: 1.2,
            iconOffset: [0, -5],
            symbolSortKey: 1,
          ),
        );
      }
    }

    await manager.createMulti(options);
  }

  Future<Uint8List> _generateAvatar(
    String? url,
    String? name,
    BuildContext context,
    bool isMe,
  ) async {
    if (url != null && url.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return await _createCircularImageFromBytes(response.bodyBytes);
        }
      } catch (_) {}
    }
    return await _createPlaceholderAvatar(name, context, isMe);
  }

  Future<Uint8List> _createCircularImageFromBytes(
    Uint8List sourceBytes, {
    double size = 140,
  }) async {
    final codec = await ui.instantiateImageCodec(
      sourceBytes,
      targetHeight: size.toInt(),
      targetWidth: size.toInt(),
    );
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..isAntiAlias = true;
    final double center = size / 2;
    final double radius = size / 2;

    canvas.drawCircle(
      Offset(center, center + 2),
      radius,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawCircle(
      Offset(center, center),
      radius,
      Paint()..color = Colors.white,
    );

    final double imageRadius = radius - 6;
    final ui.Path clipPath = ui.Path()
      ..addOval(
        Rect.fromCircle(center: Offset(center, center), radius: imageRadius),
      );
    canvas.clipPath(clipPath);

    final double srcSize = math.min(
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final double srcX = (image.width - srcSize) / 2;
    final double srcY = (image.height - srcSize) / 2;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(srcX, srcY, srcSize, srcSize),
      Rect.fromLTWH(
        center - imageRadius,
        center - imageRadius,
        imageRadius * 2,
        imageRadius * 2,
      ),
      paint,
    );

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> _createPlaceholderAvatar(
    String? name,
    BuildContext context,
    bool isMe,
  ) async {
    const double size = 140;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final double center = size / 2;
    final double radius = size / 2;

    final theme = Theme.of(context);
    final bgColor = isMe
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    canvas.drawCircle(
      Offset(center, center + 2),
      radius,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawCircle(
      Offset(center, center),
      radius,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      Offset(center, center),
      radius - 6,
      Paint()..color = bgColor,
    );

    if (name != null && name.trim().isNotEmpty) {
      final initial = name.trim().substring(0, 1).toUpperCase();
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: initial,
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center - (textPainter.width / 2),
          center - (textPainter.height / 2),
        ),
      );
    } else {
      final icon = Icons.person;
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: size * 0.6,
            fontFamily: icon.fontFamily,
            color: Colors.white,
          ),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center - (textPainter.width / 2),
          center - (textPainter.height / 2),
        ),
      );
    }

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  double? _distanceMeters(LatLng? a, LatLng? b) {
    if (a == null || b == null) return null;
    return distanceMeters(a.latitude, a.longitude, b.latitude, b.longitude);
  }
}

class _CompactDistanceChip extends StatelessWidget {
  const _CompactDistanceChip({
    required this.distanceM,
    required this.isMerged,
    required this.lang,
  });

  final double distanceM;
  final bool isMerged;
  final String lang;

  String _text() {
    if (isMerged) return lang == 'fr' ? 'Ensemble ❤️' : 'Together ❤️';
    if (distanceM < 1000) return '${distanceM.round()} m';
    return '${(distanceM / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.place,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              _text(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNamesBar extends StatelessWidget {
  const _FloatingNamesBar({
    required this.myProfile,
    required this.partnerProfile,
    required this.myPos,
    required this.partnerPos,
    this.onCenterMy,
    this.onCenterPartner,
    this.onFitBoth,
    required this.lang,
  });

  final ProfileEntity? myProfile;
  final ProfileEntity? partnerProfile;
  final LatLng? myPos;
  final LatLng? partnerPos;
  final VoidCallback? onCenterMy;
  final VoidCallback? onCenterPartner;
  final VoidCallback? onFitBoth;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AvatarChip(
            label: lang == 'fr' ? 'Moi' : 'Me',
            url: myProfile?.avatarUrl,
            isActive: myPos != null,
            onTap: onCenterMy,
          ),
          if (myPos != null && partnerPos != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: const Icon(Icons.fit_screen_outlined, size: 20),
                onPressed: onFitBoth,
                tooltip: lang == 'fr' ? 'Voir tout' : 'See all',
                visualDensity: VisualDensity.compact,
              ),
            )
          else
            const SizedBox(width: 12),
          _AvatarChip(
            label:
                partnerProfile?.username ??
                (lang == 'fr' ? 'Partenaire' : 'Partner'),
            url: partnerProfile?.avatarUrl,
            isActive: partnerPos != null,
            onTap: onCenterPartner,
          ),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({
    required this.label,
    this.url,
    required this.isActive,
    this.onTap,
  });

  final String label;
  final String? url;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withValues(alpha: 0.1),
              backgroundImage: url != null ? NetworkImage(url!) : null,
              child: url == null
                  ? Icon(Icons.person, size: 16, color: color)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapboxOnlyPlaceholder extends StatelessWidget {
  const _MapboxOnlyPlaceholder({required this.lang});
  final String lang;
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(_positionMapboxOnlyMessage(lang)));
  }
}

String _positionTitle(String lang) => lang == 'fr' ? 'Position' : 'Location';
String _positionNoPartnerMessage(String lang) =>
    lang == 'fr' ? 'Invitez votre partenaire' : 'Invite your partner';
String _positionNoPartnerSecondary(String lang) =>
    lang == 'fr' ? 'Pour partager votre position' : 'To share your location';
String _positionInvitePartner(String lang) =>
    lang == 'fr' ? 'Inviter' : 'Invite';
String _positionEnableSharingMessage(String lang) =>
    lang == 'fr' ? 'Activez la localisation' : 'Enable location';
String _positionEnableSharingSecondary(String lang) =>
    lang == 'fr' ? 'Dans les paramètres' : 'In settings';
String _positionOpenSettings(String lang) =>
    lang == 'fr' ? 'Paramètres' : 'Settings';
String _positionReloadTooltip(String lang) =>
    lang == 'fr' ? 'Actualiser' : 'Refresh';
String _positionReloadDone(String lang) => lang == 'fr' ? 'À jour' : 'Updated';
String _positionMapboxOnlyMessage(String lang) => 'Mapbox Setup Required';
