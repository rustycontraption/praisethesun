import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/model.dart';
import 'package:praisethesun/src/widgets/sun_map.dart';
import 'package:provider/provider.dart';

class SunApp extends StatelessWidget {
  const SunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SunMap(
        onTapHandler: (tapPosition, point) {
          Provider.of<SunLocationModel>(
            context,
            listen: false,
          ).setStartPoint(point);
        },
      ),
    );
  }
}
