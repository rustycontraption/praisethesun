import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/model.dart';
import 'snackbar_message.dart';

class SunMarkerButton extends StatelessWidget {
  const SunMarkerButton({super.key, required this.buttonLocation});
  final LatLng buttonLocation;
  static const double _buttonSize = 100.0;
  static const double _iconSize = 35.0;

  void _launchMap(
    BuildContext context,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    final sunModel = context.read<SunLocationModel>();
    double originLatitude = sunModel.startPoint.latitude;
    double originLongitude = sunModel.startPoint.longitude;

    try {
      String urlString = 'https://www.google.com/maps/dir/?api=1';

      urlString += '&origin=$originLatitude,$originLongitude';
      urlString += '&destination=$destinationLatitude,$destinationLongitude';

      final url = Uri.parse(urlString);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch maps');
      }
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, 'Could not launch map application: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sunModel = context.read<SunLocationModel>();

    return IconButton(
      iconSize: _iconSize,
      padding: EdgeInsets.zero,
      onPressed: () {
        _launchMap(context, buttonLocation.latitude, buttonLocation.longitude);
      },
      icon: SizedBox(
        width: _buttonSize,
        height: _buttonSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            sunModel.isItNight()
                ? Icon(
                    Icons.mode_night_rounded,
                    color: Colors.lightBlue,
                    size: _buttonSize,
                  )
                : Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.orange,
                    size: _buttonSize,
                    shadows: [Shadow(blurRadius: 5.0, color: Colors.white)],
                  ),
            Positioned(
              top: 30,
              left: sunModel.isItNight()
                  ? (_buttonSize) / 2 - 10
                  : (_buttonSize) / 2 - (_iconSize / 2),
              child: Icon(
                Icons.open_in_new,
                color: Colors.white,
                size: _iconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
