import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/model/model.dart';
import 'package:praisethesun/src/widgets/circle_layer.dart';
import 'package:praisethesun/src/widgets/marker_layer.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:praisethesun/src/model.dart';
// import 'package:provider/provider.dart';

class SunMap extends StatefulWidget {
  final SunLocationModel sunModel;
  final TapCallback onTapHandler;
  final LatLng initialCenterPoint;
  final SunMarkerLayer markerLayer;
  final SearchCircleLayer circleLayer;

  const SunMap({
    super.key,
    required this.sunModel,
    required this.onTapHandler,
    required this.initialCenterPoint,
    required this.markerLayer,
    required this.circleLayer,
  });

  @override
  State<SunMap> createState() => _SunMapState();
}

class _SunMapState extends State<SunMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  // class SunMap extends StatelessWidget {
  //   SunMap({
  //     super.key,
  //     required this.sunModel,
  //     required this.onTapHandler,
  //     required this.initialCenterPoint,
  //     required this.markerLayer,
  //   });

  //   final SunLocationModel sunModel;
  //   final TapCallback onTapHandler;
  //   final LatLng initialCenterPoint;
  //   final SunMarkerLayer markerLayer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          keepAlive: true,
          // onMapReady: () => sunModel.mapController = _mapController,
          initialCenter: widget.initialCenterPoint,
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
          widget.circleLayer,
          widget.markerLayer,
        ],
      ),
    );
  }
}
