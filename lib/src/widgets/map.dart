import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:praisethesun/src/model/model.dart';
import 'package:praisethesun/src/services/logging_service.dart';
import 'package:praisethesun/src/widgets/circle_layer.dart';
import 'package:praisethesun/src/widgets/marker_layer.dart';
import 'package:praisethesun/src/widgets/snackbar_message.dart';

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
  late final Logger _logger;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    widget.sunModel.addListener(_onSearchRadiusChanged);
    _logger = LoggingService().getLogger('SunMap');
  }

  void _onSearchRadiusChanged() async {
    final Distance distance = const Distance();

    int searchRadius;
    searchRadius = widget.sunModel.currentSearchRadius;
    LatLng neLatLng = distance.offset(
      widget.sunModel.startPoint,
      searchRadius * 1000,
      45,
    );
    LatLng swLatLng = distance.offset(
      widget.sunModel.startPoint,
      searchRadius * 1000,
      225,
    );

    try {
      final newBounds = LatLngBounds.fromPoints([neLatLng, swLatLng]);

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: newBounds,
          padding: const EdgeInsets.all(100.0),
        ),
      );
      _mapController.rotate(0);
    } catch (e) {
      _logger.severe('Error updating camera location');
      if (mounted) {
        showErrorSnackBar(context, 'Error updating camera location');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          keepAlive: true,
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
