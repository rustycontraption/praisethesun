import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/model/model.dart';
import 'package:praisethesun/src/widgets/circle_layer.dart';
import 'package:praisethesun/src/widgets/map.dart';
import 'package:praisethesun/src/widgets/marker_layer.dart';
import 'package:provider/provider.dart';

// class SunApp extends StatefulWidget {
//   const SunApp({super.key});

//   @override
//   State<SunApp> createState() => _SunAppState();
// }

// class _SunAppState extends State<SunApp> {
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
          sunLocationModel.setStartPoint(point),
        },
        initialCenterPoint: LatLng(47.60621, -122.33207),
        markerLayer: SunMarkerLayer(sunModel: sunLocationModel),
        circleLayer: SearchCircleLayer(sunModel: sunLocationModel),
      ),
    );
  }
}
