import 'dart:async';
import 'package:dio/dio.dart';
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
  CancelToken _cancelToken = CancelToken();
  final dio = Dio();

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

  void cancelSearch() {
    _isSearching = false;
    _currentSearchRadius = 0;
    _sunLocations.clear();
    _cancelToken.cancel();
    notifyListeners();
  }

  Future<void> getSunLocationFromServer([int radiusKilometers = 0]) async {
    if (radiusKilometers >= 1000) {
      cancelSearch();
      return Future.error('No sun locations found within 5000 km radius.');
    }

    Response response;
    List<LatLng> sunCoords = [];
    _currentSearchRadius = radiusKilometers;
    notifyListeners();

    final uri =
        '$sunAPIUrl?start_point_lat=${_startPoint.latitude}&start_point_lng=${_startPoint.longitude}&radiusKilometers=$radiusKilometers';

    try {
      response = await dio.get(uri, cancelToken: _cancelToken);
    } on DioException catch (error) {
      if (DioExceptionType.connectionTimeout == error.type ||
          DioExceptionType.receiveTimeout == error.type) {
        cancelSearch();
        return Future.error('Timeout when fetching sun data, try again!');
      } else if (DioExceptionType.cancel == error.type) {
        cancelSearch();
        return;
      } else {
        rethrow;
      }
    } catch (error) {
      cancelSearch();
      return Future.error('Error when fetching sun data, try again.');
    }

    if (response.statusCode == 200) {
      sunCoords = (response.data['data']['sun_location'] as List).map((item) {
        return LatLng(item['lat'], item['lng']);
      }).toList();
    } else {
      cancelSearch();
      _logger.warning(
        'Sun data API returned HTTP code: ${response.statusCode}',
      );
      return Future.error(
        'Sun data API returned HTTP code: ${response.statusCode}',
      );
    }

    if (sunCoords.isNotEmpty) {
      _sunLocations.addAll(sunCoords);
      notifyListeners();
      return;
    } else {
      return getSunLocationFromServer(radiusKilometers + 100);
    }
  }

  Future<void> returnSunLocations() async {
    _cancelToken.cancel();
    _sunLocations.clear();
    _isSearching = true;
    _cancelToken = CancelToken();
    notifyListeners();

    await getSunLocationFromServer();

    _isSearching = false;
    notifyListeners();
  }
}
