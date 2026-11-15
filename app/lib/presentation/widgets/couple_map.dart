import 'dart:convert';
import 'dart:math' show Point, atan, exp, ln2, log, max, min, pi, pow, sin;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart' as ml;

import 'package:nousdeux/core/utils/map_style.dart';

/// A picture on the map: one person, or a heart when both are together.
@immutable
class MapMarker {
  const MapMarker({
    required this.id,
    required this.position,
    required this.image,
    this.size = 1.2,
    this.zIndex = 0,
  });

  /// Also the name of the image in the map style.
  final String id;
  final ll.LatLng position;

  /// PNG bytes. Both platforms read them as physical pixels.
  final Uint8List image;
  final double size;

  /// Higher draws on top.
  final int zIndex;

  @override
  bool operator ==(Object other) =>
      other is MapMarker &&
      other.id == id &&
      other.position == position &&
      identical(other.image, image) &&
      other.size == size &&
      other.zIndex == zIndex;

  @override
  int get hashCode =>
      Object.hash(id, position, identityHashCode(image), size, zIndex);
}

/// The Position screen's map: MapLibre with OpenFreeMap tiles (OpenStreetMap
/// data, no key, no tracking), place names in the app's language, and a day
/// and a night look. Move the camera through a `GlobalKey<CoupleMapState>`.
class CoupleMap extends StatefulWidget {
  const CoupleMap({
    super.key,
    required this.initialCenter,
    required this.markers,
    required this.look,
    required this.lang,
    this.onReady,
  });

  final ll.LatLng initialCenter;
  final List<MapMarker> markers;
  final MapLook look;
  final String lang;

  /// Called once, when the first style has loaded and the camera can move.
  final VoidCallback? onReady;

  @override
  State<CoupleMap> createState() => CoupleMapState();
}

class CoupleMapState extends State<CoupleMap> {
  /// Localized styles by look and language: fetched once per app run.
  static final _styles = <String, String>{};

  ml.MapLibreMapController? _controller;
  String? _style;
  bool _styleLoaded = false;
  bool _ready = false;
  int _styleRequest = 0;

  List<MapMarker> _shown = const [];
  bool _syncing = false;
  bool _syncAgain = false;

  @override
  void initState() {
    super.initState();
    _loadStyle();
  }

  @override
  void didUpdateWidget(CoupleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.look != widget.look || oldWidget.lang != widget.lang) {
      _loadStyle();
    }
    if (!listEquals(oldWidget.markers, widget.markers)) _syncMarkers();
  }

  /// Centers the camera on [position], tilted.
  Future<void> centerOn(
    ll.LatLng position, {
    double zoom = 16.5,
    bool animated = true,
  }) async {
    final update = ml.CameraUpdate.newCameraPosition(
      ml.CameraPosition(target: _latLng(position), zoom: zoom, tilt: 45),
    );
    await _move(update, animated, const Duration(milliseconds: 1200));
  }

  /// Room kept around the two people, measured to their position (the
  /// marker's centre): the distance chip ends ~126 pt from the top and a
  /// marker is ~26 pt in radius; the names bar sits at the bottom.
  static const fitPadding = EdgeInsets.fromLTRB(50, 160, 50, 180);

  /// Fits [a] and [b] on screen, clear of the distance chip and names bar.
  ///
  /// The camera is worked out here, flat and facing north, rather than with
  /// MapLibre's bounds update, which keeps the current tilt: after "Me"
  /// (tilted 45°) it framed the wrong place and left one person off screen.
  Future<void> fitBoth(ll.LatLng a, ll.LatLng b, {bool animated = true}) async {
    final box = context.findRenderObject();
    final size = box is RenderBox && box.hasSize ? box.size : null;
    if (size == null || size.isEmpty) return;
    final update = ml.CameraUpdate.newCameraPosition(
      cameraToFit(a, b, size, fitPadding),
    );
    await _move(update, animated, const Duration(milliseconds: 1500));
  }

  Future<void> _move(
    ml.CameraUpdate update,
    bool animated,
    Duration duration,
  ) async {
    final controller = _controller;
    if (controller == null) return;
    if (animated) {
      await controller.animateCamera(update, duration: duration);
    } else {
      await controller.moveCamera(update);
    }
  }

  Future<void> _loadStyle() async {
    final request = ++_styleRequest;
    final style = await _styleFor(widget.look, widget.lang);
    if (!mounted || request != _styleRequest || style == _style) return;
    final controller = _controller;
    if (controller == null) {
      // The first style creates the map in build().
      setState(() => _style = style);
      return;
    }
    _style = style;
    _styleLoaded = false;
    await controller.setStyle(style);
  }

  /// The OpenFreeMap style with its labels in [lang]. Without a network
  /// answer the published style is used as is (English labels, still a map).
  static Future<String> _styleFor(MapLook look, String lang) async {
    final cacheKey = '${look.name}/$lang';
    final cached = _styles[cacheKey];
    if (cached != null) return cached;
    final url = mapStyleUrl(look);
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final style =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return _styles[cacheKey] = jsonEncode(localizeMapLabels(style, lang));
      }
    } catch (_) {
      // Offline or a bad answer: fall through to the plain URL.
    }
    return url;
  }

  Future<void> _onStyleLoaded() async {
    _styleLoaded = true;
    // Images belong to the style, so a new style needs them again.
    _shown = const [];
    if (!_ready) {
      _ready = true;
      widget.onReady?.call();
    }
    final controller = _controller;
    if (controller == null) return;
    // By default an icon that collides with another is hidden: keep both
    // people visible when close (the higher zIndex draws on top), and let the
    // map's own labels show around them.
    await controller.setSymbolIconAllowOverlap(true);
    await controller.setSymbolIconIgnorePlacement(true);
    await _syncMarkers();
  }

  /// Puts [CoupleMap.markers] on the map. Runs one update at a time; a change
  /// that arrives meanwhile is applied right after.
  Future<void> _syncMarkers() async {
    if (_syncing) {
      _syncAgain = true;
      return;
    }
    _syncing = true;
    try {
      do {
        _syncAgain = false;
        final controller = _controller;
        final markers = widget.markers;
        if (controller == null || !_styleLoaded) return;
        if (listEquals(markers, _shown)) continue;
        for (final marker in markers) {
          await controller.addImage(marker.id, marker.image);
        }
        await controller.clearSymbols();
        if (markers.isNotEmpty) {
          await controller.addSymbols([
            for (final marker in markers)
              ml.SymbolOptions(
                geometry: _latLng(marker.position),
                iconImage: marker.id,
                iconSize: marker.size,
                zIndex: marker.zIndex,
              ),
          ]);
        }
        _shown = markers;
      } while (_syncAgain && mounted);
    } finally {
      _syncing = false;
    }
  }

  static ml.LatLng _latLng(ll.LatLng p) => ml.LatLng(p.latitude, p.longitude);

  @override
  Widget build(BuildContext context) {
    final style = _style;
    if (style == null) {
      return ColoredBox(color: Theme.of(context).colorScheme.surface);
    }
    return ml.MapLibreMap(
      styleString: style,
      initialCameraPosition: ml.CameraPosition(
        target: _latLng(widget.initialCenter),
        zoom: 13,
      ),
      onMapCreated: (controller) => _controller = controller,
      onStyleLoadedCallback: _onStyleLoaded,
      compassEnabled: false,
      myLocationEnabled: false,
      // The (i) button shows the OpenFreeMap and OpenStreetMap credits that
      // their licences require. It sits above the names bar.
      attributionButtonPosition: ml.AttributionButtonPosition.bottomRight,
      attributionButtonMargins: const Point(12, 112),
    );
  }
}

/// MapLibre's world size at zoom 0, in logical pixels.
const double _worldTile = 512;

double _mercatorX(double lng) => (lng + 180) / 360;

double _mercatorY(double lat) {
  final s = sin(lat * pi / 180);
  return 0.5 - log((1 + s) / (1 - s)) / (4 * pi);
}

double _lngFromX(double x) => x * 360 - 180;

double _latFromY(double y) {
  final t = pi * (1 - 2 * y);
  return atan((exp(t) - exp(-t)) / 2) * 180 / pi;
}

/// The flat, north-up camera that shows [a] and [b] inside a map of [size]
/// minus [padding], as close as [maxZoom] allows.
@visibleForTesting
ml.CameraPosition cameraToFit(
  ll.LatLng a,
  ll.LatLng b,
  Size size,
  EdgeInsets padding, {
  double maxZoom = 17,
}) {
  final ax = _mercatorX(a.longitude), bx = _mercatorX(b.longitude);
  final ay = _mercatorY(a.latitude), by = _mercatorY(b.latitude);
  final width = max(1.0, size.width - padding.horizontal);
  final height = max(1.0, size.height - padding.vertical);
  final dx = (ax - bx).abs(), dy = (ay - by).abs();
  final zoomX = dx == 0 ? maxZoom : log(width / (dx * _worldTile)) / ln2;
  final zoomY = dy == 0 ? maxZoom : log(height / (dy * _worldTile)) / ln2;
  final zoom = min(maxZoom, min(zoomX, zoomY));
  final scale = _worldTile * pow(2, zoom);
  // The two people sit at the middle of the padded box, so the screen's
  // centre is offset from them by half the padding difference.
  final x = (ax + bx) / 2 + (padding.right - padding.left) / 2 / scale;
  final y = (ay + by) / 2 + (padding.bottom - padding.top) / 2 / scale;
  return ml.CameraPosition(
    target: ml.LatLng(_latFromY(y), _lngFromX(x)),
    zoom: zoom,
    tilt: 0,
    bearing: 0,
  );
}

/// Where [p] lands on a map of [size] seen through [camera] (flat, north-up).
@visibleForTesting
Offset screenPoint(ll.LatLng p, ml.CameraPosition camera, Size size) {
  final scale = _worldTile * pow(2, camera.zoom);
  final cx = _mercatorX(camera.target.longitude);
  final cy = _mercatorY(camera.target.latitude);
  return Offset(
    size.width / 2 + (_mercatorX(p.longitude) - cx) * scale,
    size.height / 2 + (_mercatorY(p.latitude) - cy) * scale,
  );
}
