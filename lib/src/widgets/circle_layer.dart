import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:praisethesun/src/model/model.dart';
import 'package:provider/provider.dart';

class SearchCircleLayer extends StatelessWidget {
  const SearchCircleLayer({super.key, required this.sunModel});

  final SunLocationModel sunModel;

  @override
  Widget build(BuildContext context) {
    return Consumer<SunLocationModel>(
      builder: (context, sunModel, child) {
        return CircleLayer(
          circles: [
            CircleMarker(
              point: sunModel.startPoint,
              radius: sunModel.currentSearchRadius * 1000,
              useRadiusInMeter: true,
              color: Colors.orange.withAlpha(50),
              borderColor: Colors.orange,
              borderStrokeWidth: 2,
            ),
          ],
        );
      },
    );
  }
}
