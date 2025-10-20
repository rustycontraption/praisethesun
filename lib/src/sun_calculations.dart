import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart';
import 'dart:math' as math;

class CalculateSun {
  final Logger log = Logger('CalculateSun');
  final int coordSeparation = 100;
  final int earthRadius = 6371;

  List<LatLng> _calculateCoords(
    double startLat,
    double startLng,
    double radius,
  ) {
    List<LatLng> coords = [];
    double startLatRad = startLat * (math.pi / 180);
    double startLngRad = startLng * (math.pi / 180);
    double radiusRad = radius / earthRadius;

    int coordQuantity = (math.pi / math.asin(coordSeparation / (2 * radius)))
        .floor();

    for (int i = 0; i < coordQuantity; i++) {
      double bearing = (2 * math.pi * i) / coordQuantity;
      double newLatRad = math.asin(
        math.sin(startLatRad) * math.cos(radiusRad) +
            math.cos(startLatRad) * math.sin(radiusRad) * math.cos(bearing),
      );

      double newLngRad =
          startLngRad +
          math.atan2(
            math.sin(bearing) * math.sin(radiusRad) * math.cos(startLatRad),
            math.cos(radiusRad) - math.sin(startLatRad) * math.sin(newLatRad),
          );
      double newLat = newLatRad * (180 / math.pi);
      double newLng = newLngRad * (180 / math.pi);

      // Normalize longitude to [-180, 180]
      newLng = ((newLng + 540) % 360) - 180;
      coords.add(LatLng(newLat, newLng));
    }
    return coords;
  }

  Future<List<LatLng>> getClearWeather({
    required double startPointLat,
    required double startPointLng,
    List<LatLng> coords = const [],
    double radius = 0,
  }) async {
    if (radius >= 1000) {
      log.warning('Max radius reached, no clear weather found.');
      return List<LatLng>.empty();
    }

    List<LatLng> clearCoords = [];

    try {
      final startUri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$startPointLat&longitude=$startPointLng&current=weather_code&timezone=auto',
      );
      final response = await get(startUri);

      if (response.statusCode == 200) {
        final weatherData = jsonDecode(response.body);
        if (weatherData["current"]["weather_code"] == 0) {
          clearCoords.add(LatLng(startPointLat, startPointLng));
          return clearCoords;
        }
      } else {
        throw Exception(
          'HTTP error ${response.statusCode}, ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      log.severe('Error fetching weather data: $e');
    }

    for (LatLng coord in coords) {
      try {
        final uri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${coord.latitude}&longitude=${coord.longitude}&current=weather_code&timezone=auto',
        );
        final response = await get(uri);

        if (response.statusCode == 200) {
          final weatherData = jsonDecode(response.body);
          if (weatherData["current"]["weather_code"] == 0) {
            clearCoords.add(coord);
          }
        } else {
          throw Exception(
            'HTTP error ${response.statusCode}, ${response.reasonPhrase}',
          );
        }
      } catch (e) {
        log.severe('Error fetching weather data: $e');
      }
    }
    if (clearCoords.isNotEmpty) {
      return clearCoords;
    } else {
      radius += 100;
      List<LatLng> newCoords = _calculateCoords(
        startPointLat,
        startPointLng,
        radius,
      );
      getClearWeather(
        startPointLat: startPointLat,
        startPointLng: startPointLng,
        coords: newCoords,
        radius: radius,
      );
    }
    return List<LatLng>.empty();
  }
}
