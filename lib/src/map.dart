import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
import 'model.dart';
import 'package:provider/provider.dart';

class SunMap extends StatefulWidget {
  const SunMap({super.key});

  @override
  State<SunMap> createState() => _SunMapState();
}

class _SunMapState extends State<SunMap> {
  // LatLng startPointMap = LatLng(47.60621, -122.33207);
  // Marker get startMarker => Marker(
  //   point: startPointMap,
  //   width: 80,
  //   height: 80,
  //   child: FindSun(),
  // );

  // void _setStartMarker(LatLng position) {
  //   setState(() {
  //     startPointMap = position;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final sunModel = Provider.of<SunLocationModel>(context);
    final startMarker = Marker(
      point: sunModel.startPoint,
      width: 80,
      height: 80,
      child: const FindSun(),
    );
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(bounds: sunModel.bounds),
          initialZoom: 10,
          onTap: (tapPosition, point) => sunModel.setStartPoint(point),
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
          MarkerLayer(markers: [startMarker]),
        ],
      ),
    );
  }
}

class FindSun extends StatelessWidget {
  const FindSun({super.key});

  @override
  Widget build(BuildContext context) {
    final sunModel = Provider.of<SunLocationModel>(context);

    return IconButton(
      iconSize: 48,
      padding: EdgeInsets.zero,
      onPressed: () => print(sunModel.startPoint),
      icon: const Icon(Icons.search),
      style: IconButton.styleFrom(backgroundColor: Colors.white),
    );
  }
}
