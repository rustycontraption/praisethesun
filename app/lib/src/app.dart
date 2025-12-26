import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'model/model.dart';
import 'widgets/circle_layer.dart';
import 'widgets/map.dart';
import 'widgets/marker_layer.dart';

void _handleMap(SunLocationModel sunLocationModel, LatLng point) {
  if (sunLocationModel.isSearching) {
    return;
  }
  sunLocationModel.setStartPoint(point);
}

class SunApp extends StatelessWidget {
  const SunApp({super.key});
  @override
  Widget build(BuildContext context) {
    final sunLocationModel = Provider.of<SunLocationModel>(
      context,
      listen: false,
    );

    return Scaffold(
      body: SunMap(
        sunModel: sunLocationModel,
        onTapHandler: (tapPosition, point) => {
          _handleMap(sunLocationModel, point),
        },
        initialCenterPoint: LatLng(47.60621, -122.33207),
        markerLayer: SunMarkerLayer(),
        circleLayer: SearchCircleLayer(),
      ),
    );
  }
}
