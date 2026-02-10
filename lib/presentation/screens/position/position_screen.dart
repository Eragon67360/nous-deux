import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/utils/geo_utils.dart';
import 'package:nousdeux/domain/entities/location_sharing_entity.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/presentation/providers/location_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';

/// Position tab: map with both partners' locations, distance, tap-to-center names.
class PositionScreen extends ConsumerStatefulWidget {
  const PositionScreen({super.key});

  @override
  ConsumerState<PositionScreen> createState() => _PositionScreenState();
}

class _PositionScreenState extends ConsumerState<PositionScreen> {
  final MapController _mapController = MapController();
  RealtimeChannel? _locationChannel;
  String? _subscribedCoupleId;

  @override
  void initState() {
    super.initState();
  }

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
            ref.invalidate(myLocationSharingProvider);
            ref.invalidate(partnerLocationSharingProvider);
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _locationChannel?.unsubscribe();
    ref.read(locationUpdateNotifierProvider.notifier).stop();
    super.dispose();
  }

  String _lang() =>
      ref.read(myProfileProvider).valueOrNull?.language ?? 'fr';

  Future<void> _reload() async {
    final myLocation = await ref.read(myLocationSharingProvider.future);
    if (myLocation?.isSharing == true) {
      await ref.read(locationUpdateNotifierProvider.notifier).pushCurrentPosition();
    }
    ref.invalidate(myLocationSharingProvider);
    ref.invalidate(partnerLocationSharingProvider);
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

    // Subscribe to location realtime when we have a couple
    coupleAsync.whenData((c) {
      if (c != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _subscribeToLocationRealtime(c.id);
        });
      }
    });

    // Start/stop location update timer when sharing (only on value change to avoid restarting every build)
    ref.listen<AsyncValue<LocationSharingEntity?>>(myLocationSharingProvider, (prev, next) {
      final isSharing = next.valueOrNull?.isSharing ?? false;
      if (isSharing && mounted) {
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

    // No partner
    if (!hasPartner) {
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
        body: EmptyState(
          icon: Icons.location_off_outlined,
          message: _positionNoPartnerMessage(_lang()),
          secondary: _positionNoPartnerSecondary(_lang()),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FilledButton.icon(
              onPressed: () => context.push('/pairing'),
              icon: const Icon(Icons.person_add_outlined),
              label: Text(_positionInvitePartner(_lang())),
            ),
          ),
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

    // Partner but no positions to show
    if (!hasAnyPosition) {
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
        body: EmptyState(
          icon: Icons.location_on_outlined,
          message: _positionEnableSharingMessage(_lang()),
          secondary: _positionEnableSharingSecondary(_lang()),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/main/settings'),
              icon: const Icon(Icons.settings_outlined),
              label: Text(_positionOpenSettings(_lang())),
            ),
          ),
        ),
      );
    }

    // Map with at least one position
    final distanceM = _distanceMeters(myPos, partnerPos);
    final isMerged = distanceM != null && distanceM < positionMergeThresholdMeters;
    final center = _centerPoint(myPos, partnerPos);
    final zoom = _suggestedZoom(myPos, partnerPos);

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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: zoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nousdeux.app',
              ),
              MarkerLayer(
                markers: _buildMarkers(
                  myPos: myPos,
                  partnerPos: partnerPos,
                  isMerged: isMerged,
                  myProfile: myProfile,
                  partnerProfile: partnerProfile,
                ),
              ),
            ],
          ),
          // Distance card (warm styling)
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isMerged ? Icons.favorite : Icons.straighten,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatDistance(distanceM, isMerged, _lang()),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _NamesBar(
          myProfile: myProfile,
          partnerProfile: partnerProfile,
          myPos: myPos,
          partnerPos: partnerPos,
          mapController: _mapController,
          lang: _lang(),
        ),
      ),
    );
  }

  List<Marker> _buildMarkers({
    required LatLng? myPos,
    required LatLng? partnerPos,
    required bool isMerged,
    required ProfileEntity? myProfile,
    required ProfileEntity? partnerProfile,
  }) {
    const markerSize = 44.0;
    const mergedSize = 56.0;
    final theme = Theme.of(context);

    if (isMerged && myPos != null) {
      return [
        Marker(
          point: myPos,
          width: mergedSize,
          height: mergedSize,
          child: _MergedAvatarMarker(
            myAvatarUrl: myProfile?.avatarUrl,
            partnerAvatarUrl: partnerProfile?.avatarUrl,
            theme: theme,
          ),
        ),
      ];
    }

    final markers = <Marker>[];
    if (myPos != null) {
      markers.add(
        Marker(
          point: myPos,
          width: markerSize,
          height: markerSize,
          child: _AvatarMarker(
            avatarUrl: myProfile?.avatarUrl,
            theme: theme,
          ),
        ),
      );
    }
    if (partnerPos != null) {
      markers.add(
        Marker(
          point: partnerPos,
          width: markerSize,
          height: markerSize,
          child: _AvatarMarker(
            avatarUrl: partnerProfile?.avatarUrl,
            theme: theme,
          ),
        ),
      );
    }
    return markers;
  }

  double? _distanceMeters(LatLng? a, LatLng? b) {
    if (a == null || b == null) return null;
    return distanceMeters(a.latitude, a.longitude, b.latitude, b.longitude);
  }

  LatLng _centerPoint(LatLng? myPos, LatLng? partnerPos) {
    if (myPos != null && partnerPos != null) {
      return LatLng(
        (myPos.latitude + partnerPos.latitude) / 2,
        (myPos.longitude + partnerPos.longitude) / 2,
      );
    }
    if (myPos != null) return myPos;
    if (partnerPos != null) return partnerPos;
    return const LatLng(46.0, 2.0); // France fallback
  }

  double _suggestedZoom(LatLng? myPos, LatLng? partnerPos) {
    if (myPos == null && partnerPos == null) return 5.0;
    if (myPos == null || partnerPos == null) return 14.0;
    final d = _distanceMeters(myPos, partnerPos)!;
    if (d < 100) return 16.0;
    if (d < 1000) return 14.0;
    if (d < 10000) return 12.0;
    if (d < 100000) return 10.0;
    return 7.0;
  }

  String _formatDistance(double? meters, bool isMerged, String lang) {
    if (isMerged) return lang == 'fr' ? 'Ensemble' : 'Together';
    if (meters == null) return '—';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}

// --- Name bar: tap to center map ---
class _NamesBar extends StatelessWidget {
  const _NamesBar({
    required this.myProfile,
    required this.partnerProfile,
    required this.myPos,
    required this.partnerPos,
    required this.mapController,
    required this.lang,
  });

  final ProfileEntity? myProfile;
  final ProfileEntity? partnerProfile;
  final LatLng? myPos;
  final LatLng? partnerPos;
  final MapController mapController;
  final String lang;

  String _myLabel() => lang == 'fr' ? 'Moi' : 'Me';
  String _partnerLabel() {
    final name = partnerProfile?.username?.trim();
    return (name != null && name.isNotEmpty) ? name : (lang == 'fr' ? 'Partenaire' : 'Partner');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canTapMy = myPos != null;
    final canTapPartner = partnerPos != null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NameChip(
            label: _myLabel(),
            onTap: canTapMy
                ? () {
                    mapController.move(myPos!, 15.0);
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              '–',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _NameChip(
            label: _partnerLabel(),
            onTap: canTapPartner
                ? () {
                    mapController.move(partnerPos!, 15.0);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _NameChip extends StatelessWidget {
  const _NameChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: enabled
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarMarker extends StatelessWidget {
  const _AvatarMarker({this.avatarUrl, required this.theme});

  final String? avatarUrl;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: avatarUrl == null
            ? Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant)
            : null,
      ),
    );
  }
}

class _MergedAvatarMarker extends StatelessWidget {
  const _MergedAvatarMarker({
    this.myAvatarUrl,
    this.partnerAvatarUrl,
    required this.theme,
  });

  final String? myAvatarUrl;
  final String? partnerAvatarUrl;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: myAvatarUrl != null ? NetworkImage(myAvatarUrl!) : null,
              child: myAvatarUrl == null
                  ? Icon(Icons.person, size: 20, color: theme.colorScheme.onSurfaceVariant)
                  : null,
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: partnerAvatarUrl != null ? NetworkImage(partnerAvatarUrl!) : null,
              child: partnerAvatarUrl == null
                  ? Icon(Icons.person, size: 20, color: theme.colorScheme.onSurfaceVariant)
                  : null,
            ),
          ),
        ),
        Icon(
          Icons.favorite,
          color: theme.colorScheme.primary,
          size: 22,
        ),
      ],
    );
  }
}

String _positionTitle(String lang) => lang == 'fr' ? 'Position' : 'Location';
String _positionNoPartnerMessage(String lang) =>
    lang == 'fr'
        ? 'Invitez votre partenaire pour voir vos positions.'
        : 'Invite your partner to see your positions.';
String _positionNoPartnerSecondary(String lang) =>
    lang == 'fr'
        ? 'Une fois reliés, vous pourrez partager votre position sur la carte.'
        : 'Once connected, you can share your position on the map.';
String _positionInvitePartner(String lang) =>
    lang == 'fr' ? 'Inviter mon partenaire' : 'Invite my partner';
String _positionEnableSharingMessage(String lang) =>
    lang == 'fr'
        ? 'Activez le partage de position pour voir la carte.'
        : 'Enable location sharing to see the map.';
String _positionEnableSharingSecondary(String lang) =>
    lang == 'fr'
        ? 'Dans Paramètres, activez « Partager ma position ».'
        : 'In Settings, turn on « Share my location ».';
String _positionOpenSettings(String lang) =>
    lang == 'fr' ? 'Ouvrir les paramètres' : 'Open settings';
String _positionReloadTooltip(String lang) =>
    lang == 'fr' ? 'Actualiser la position' : 'Refresh position';
String _positionReloadDone(String lang) =>
    lang == 'fr' ? 'Position actualisée' : 'Position updated';
