import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:praisethesun/src/services/logging_service.dart';

class SunLocationModel extends ChangeNotifier {
  final Logger _logger;
  final String sunAPIUrl = 'http://10.0.2.2:8000/sun/';
  final List<LatLng> _sunLocations = [];
  LatLng _startPoint = LatLng(47.60621, -122.33207);
  bool _isSearching = false;
  int _currentSearchRadius = 0;

  SunLocationModel({required LoggingService loggingService})
    : _logger = loggingService.getLogger('SunLocationModel');

  LatLng get startPoint => _startPoint;
  List<LatLng> get sunLocations => _sunLocations;
  bool get isSearching => _isSearching;
  int get currentSearchRadius => _currentSearchRadius;

  void setStartPoint(LatLng newStartPoint) {
    _startPoint = newStartPoint;
    notifyListeners();
  }

  Future<void> getSunLocationFromServer([int radiusKilometers = 0]) async {
    http.Response response;
    List<LatLng> sunCoords = [];

    _isSearching = true;
    _currentSearchRadius = radiusKilometers;
    _sunLocations.clear();
    notifyListeners();

    final uri = Uri.parse(
      '$sunAPIUrl?start_point_lat=${_startPoint.latitude}&start_point_lng=${_startPoint.longitude}&radiusKilometers=$radiusKilometers',
    );

    try {
      response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Connection to sun data API timed out');
            },
          );
      _logger.info('Calling sun API for radius $radiusKilometers kilometers');
    } on TimeoutException {
      _logger.severe('Timeout when fetching from sun data API');
      return Future.error('Timeout when fetching sun data');
    } on http.ClientException catch (error) {
      _logger.severe(
        'HTTP Client Exception when fetching from sun data API: $error',
      );
      return Future.error('HTTP client exception when fetching sun data');
    } catch (error) {
      _logger.severe('Error when fetching from sun data API: $error');
      return Future.error('Error when fetching sun data');
    }

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      sunCoords = (jsonResponse['data'] as List).map((item) {
        return LatLng(item['lat'], item['lng']);
      }).toList();
    } else {
      _logger.warning(
        'Sun data API returned HTTP code: ${response.statusCode}',
      );
      return Future.error(
        'Sun data API returned HTTP code: ${response.statusCode}',
      );
    }

    if (sunCoords.isNotEmpty) {
      _sunLocations.clear();
      _sunLocations.addAll(sunCoords);
      _isSearching = false;
      _currentSearchRadius = 0;
      notifyListeners();
      return;
    } else {
      return getSunLocationFromServer(radiusKilometers += 100);
    }
  }
}
