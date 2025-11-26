import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SunMarkerButton extends StatelessWidget {
  const SunMarkerButton({super.key, required this.buttonLocation});
  final LatLng buttonLocation;
  static const double _buttonSize = 80.0;
  static const double _iconSize = 40.0;
  static const double _iconOffset = 12.0;

  void _displayMarkerData(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sun Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Latitude: ${buttonLocation.latitude.toString()}'),
              const SizedBox(height: 8),
              Text('Longitude: ${buttonLocation.longitude.toString()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: _iconSize,
      padding: EdgeInsets.zero,
      onPressed: () => _displayMarkerData(context),
      icon: SizedBox(
        width: _buttonSize,
        height: _buttonSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.orange,
              size: _buttonSize,
            ),
            const Positioned(
              top: _iconOffset,
              left: 0,
              right: 0,
              child: Icon(Icons.wb_sunny, color: Colors.white, size: _iconSize),
            ),
          ],
        ),
      ),
    );
    // child: Icon(Icons.wb_sunny, color: Colors.orange, size: 48),
    // ),
    // style: IconButton.styleFrom(foregroundColor: Colors.orange),
  }
}
