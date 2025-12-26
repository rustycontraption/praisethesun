import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../model/model.dart';

class SearchCircleLayer extends StatelessWidget {
  const SearchCircleLayer({super.key});

  CircleMarker searchCircle(SunLocationModel sunModel) {
    return CircleMarker(
      point: sunModel.startPoint,
      radius: sunModel.isSearching ? sunModel.currentSearchRadius * 1000 : 0,
      useRadiusInMeter: true,
      color: Colors.orange.withAlpha(50),
      borderColor: Colors.orange,
      borderStrokeWidth: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SunLocationModel>(
      builder: (context, sunModel, child) {
        return CircleLayer(circles: [searchCircle(sunModel)]);
      },
    );
  }
}
