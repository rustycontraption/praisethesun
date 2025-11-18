import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/model/model.dart';
import 'package:praisethesun/src/widgets/find_sun_button.dart';
import 'package:praisethesun/src/widgets/show_sun_marker_data.dart';
import 'package:provider/provider.dart';

class SunMarkerLayer extends StatelessWidget {
  SunMarkerLayer({super.key});

  final List<Marker> _markers = [];

  Marker startLocationMarker(LatLng newPoint) {
    return Marker(
      point: newPoint,
      width: 100,
      height: 100,
      child: FindSunButton(),
    );
  }

  Marker sunLocationMarker(LatLng newPoint) {
    return Marker(
      point: newPoint,
      width: 100,
      height: 100,
      child: ShowSunMarkerData(buttonLocation: newPoint),
    );
  }

  void _updateMarkers(SunLocationModel sunModel) {
    _markers.clear();
    _markers.add(startLocationMarker(sunModel.startPoint));

    if (sunModel.sunLocations.isNotEmpty) {
      _markers.addAll(
        sunModel.sunLocations.map((latlng) => sunLocationMarker(latlng)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SunLocationModel>(
      builder: (context, sunModel, child) {
        _updateMarkers(sunModel);
        return MarkerLayer(markers: _markers);
      },
    );
  }
}
