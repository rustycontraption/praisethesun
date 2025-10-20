import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/widgets/find_sun_button.dart';

Marker startLocationMarker(LatLng newPoint) {
  return Marker(point: newPoint, width: 80, height: 80, child: FindSunButton());
}

Marker sunLocationMarker(LatLng newPoint) {
  return Marker(
    point: newPoint,
    width: 64,
    height: 64,
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.wb_sunny, color: Colors.orange, size: 48),
    ),
  );
}
