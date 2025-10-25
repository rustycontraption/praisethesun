import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:praisethesun/src/model/model.dart';
import 'package:praisethesun/src/widgets/snackbar_message.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'package:praisethesun/src/services/logging_service.dart';

class FindSunButton extends StatefulWidget {
  const FindSunButton({super.key});

  @override
  State<FindSunButton> createState() => _FindSunButtonState();
}

class _FindSunButtonState extends State<FindSunButton> {
  static const double _buttonSize = 64.0;
  static const double _iconSize = 48.0;
  static const double _mapPadding = 100.0;

  bool _isLoading = false;
  late final Logger _logger;

  @override
  void initState() {
    super.initState();
    _logger = LoggingService().getLogger('FindSunButton');
  }

  _updateCameraLocation() {
    final sunModel = context.read<SunLocationModel>();

    try {
      final mapController = MapController.of(context);
      if (sunModel.sunLocations.isEmpty) return;

      final newBounds = LatLngBounds.fromPoints([
        sunModel.startPoint,
        ...sunModel.sunLocations,
      ]);

      mapController.fitCamera(
        CameraFit.bounds(
          bounds: newBounds,
          padding: const EdgeInsets.all(_mapPadding),
        ),
      );
      mapController.rotate(0);
    } catch (e) {
      _logger.severe('Error updating camera location');
      showErrorSnackBar(context, 'Error updating camera location');
    }
  }

  Future<void> _handleSun() async {
    final sunModel = context.read<SunLocationModel>();

    setState(() {
      _isLoading = true;
    });

    try {
      await sunModel.getSunLocationFromServer();
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.toString());
      }
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    if (mounted) {
      _updateCameraLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: _iconSize,
      padding: EdgeInsets.zero,
      onPressed: _isLoading ? null : () => _handleSun(),
      icon: Container(
        width: _buttonSize,
        height: _buttonSize,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.search),
            if (_isLoading)
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(color: Colors.orange),
              ),
          ],
        ),
      ),
      style: IconButton.styleFrom(foregroundColor: Colors.orange),
    );
  }
}
