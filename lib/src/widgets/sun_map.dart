import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/model.dart';
import 'package:provider/provider.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:praisethesun/src/model.dart';
// import 'package:provider/provider.dart';

class SunMap extends StatefulWidget {
  // final List<Marker> markers;
  final TapCallback onTapHandler;
  // final LatLng initialCenterPoint;

  const SunMap({
    super.key,
    // required this.markers,
    required this.onTapHandler,
    // required this.initialCenterPoint,
  });

  @override
  State<SunMap> createState() => _SunMapState();
}

class _SunMapState extends State<SunMap> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    // final sunModel = Provider.of<SunLocationModel>(context);
    print("🐞 FLUTTER MAP REBUILT");
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          // initialCenter: widget.initialCenterPoint,
          initialCenter: LatLng(47.60621, -122.33207),
          initialZoom: 10,
          maxZoom: 12,
          onTap: widget.onTapHandler,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.annejulian.praisethesun.app',
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '© OpenStreetMap contributors  ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          Consumer<SunLocationModel>(
            builder: (context, sunModel, child) {
              print("🔄 MARKER LAYER REBUILT");
              return MarkerLayer(markers: sunModel.markers);
            },
          ),
        ],
      ),
    );
  }
}
