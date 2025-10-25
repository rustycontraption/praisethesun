import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/model/model.dart';
import 'package:praisethesun/src/widgets/find_sun_button.dart';
import 'package:provider/provider.dart';

class SunMarkerLayer extends StatelessWidget {
  SunMarkerLayer({super.key, required this.sunModel});

  final List<Marker> _markers = [];
  final SunLocationModel sunModel;

  Marker get _startMarker => startLocationMarker(sunModel.startPoint);

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

  void _updateMarkers() {
    _markers.clear();
    _markers.add(_startMarker);

    if (sunModel.sunLocations.isNotEmpty) {
      _markers.addAll(
        sunModel.sunLocations.map((latlng) => sunLocationMarker(latlng)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final SunLocationModel sunModel = Provider.of<SunLocationModel>(context);

    return ListenableBuilder(
      listenable: sunModel,
      builder: (context, child) {
        _updateMarkers();
        return MarkerLayer(markers: _markers);
      },
    );
  }
}
