import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../model/model.dart';
import 'find_sun_button.dart';
import 'sun_marker.dart';

class SunMarkerLayer extends StatelessWidget {
  const SunMarkerLayer({super.key});

  Marker startLocationMarker(LatLng newPoint) {
    return Marker(
      point: newPoint,
      width: 80,
      height: 80,
      child: FindSunButton(),
    );
  }

  Marker sunLocationMarker(LatLng newPoint) {
    return Marker(
      point: newPoint,
      width: 100,
      height: 100,
      child: SunMarkerButton(buttonLocation: newPoint),
    );
  }

  List<Marker> buildMarkers(SunLocationModel sunModel) {
    final markers = <Marker>[];
    markers.add(startLocationMarker(sunModel.startPoint));

    if (sunModel.sunLocations.isNotEmpty) {
      markers.addAll(
        sunModel.sunLocations.map((latlng) => sunLocationMarker(latlng)),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SunLocationModel>(
      builder: (context, sunModel, child) {
        return MarkerLayer(markers: buildMarkers(sunModel));
      },
    );
  }
}
