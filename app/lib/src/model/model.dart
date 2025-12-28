import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/model/sun_api_client.dart';
import 'package:praisethesun/src/services/sun_logging.dart';

enum MessageType { info, error }

class SunLocationModel extends ChangeNotifier {
  final Logger _logger = SunLogging.getLogger('SunLocationModel');
  final String sunAPIUrl = 'http://10.0.2.2:8000/sun/';
  final List<LatLng> _sunLocations = [];
  final SunApiClient api;
  late final Dio dio;
  CancelToken _cancelToken = CancelToken();
  LatLng _startPoint = LatLng(47.60621, -122.33207);
  bool _isSearching = false;
  int _currentSearchRadius = 0;
  final int _maxSearchRadius = 1000;
  String? _errorMessage;
  String? _infoMessage;

  SunLocationModel({SunApiClient? apiClient})
    : api = apiClient ?? SunApiClient();

  LatLng get startPoint => _startPoint;
  List<LatLng> get sunLocations => _sunLocations;
  bool get isSearching => _isSearching;
  int get currentSearchRadius => _currentSearchRadius;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  void setSystemMessage(String message, MessageType messageType) {
    switch (messageType) {
      case MessageType.error:
        _errorMessage = message;
        _infoMessage = null;
      case MessageType.info:
        _infoMessage = message;
        _errorMessage = null;
    }
    notifyListeners();
  }

  void clearSystemMessage() {
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void setStartPoint(LatLng newStartPoint) {
    _startPoint = newStartPoint;
    notifyListeners();
  }

  void stopSearch() {
    _isSearching = false;
    _currentSearchRadius = 0;
    _sunLocations.clear();
    _cancelToken.cancel();
    notifyListeners();
  }

  Future<void> returnSunLocations([int radiusKilometers = 0]) async {
    _sunLocations.clear();
    _isSearching = true;
    _cancelToken = CancelToken();
    _currentSearchRadius = radiusKilometers;
    notifyListeners();

    List<LatLng> sunCoords = [];

    if (radiusKilometers >= _maxSearchRadius) {
      stopSearch();
      setSystemMessage(
        'No sun locations found within a $_maxSearchRadius km radius.',
        MessageType.info,
      );
      _logger.info(_infoMessage);
      return;
    }

    try {
      sunCoords = await api.getSunLocationFromServer(
        startPoint: _startPoint,
        cancelToken: _cancelToken,
        radiusKilometers: radiusKilometers,
      );
    } on DioException catch (error) {
      stopSearch();
      switch (error.type) {
        case DioExceptionType.cancel:
          setSystemMessage('Search cancelled by user.', MessageType.info);
          _logger.info('Search cancelled by user.');
        case DioExceptionType.connectionTimeout:
          setSystemMessage(
            "Oops, I wasn't able to reach the internet.",
            MessageType.error,
          );
          _logger.severe('Connection timed out during search.');
        case DioExceptionType.receiveTimeout:
          setSystemMessage(
            "Oops, I wasn't able to reach the internet.",
            MessageType.error,
          );
          _logger.severe('Receive timed out during search.');
        case DioExceptionType.sendTimeout:
          setSystemMessage("Search timed out. Try again!", MessageType.error);
          _logger.severe('Send timed out during search.');
        case DioExceptionType.badResponse:
          setSystemMessage(
            'Server error: ${error.response?.statusCode}. Contact the dev!',
            MessageType.error,
          );
          _logger.severe(
            'Search failed due to server error: ${error.response?.statusCode}',
          );
        default:
          rethrow;
      }
      return;
    } catch (error) {
      stopSearch();
      setSystemMessage('Search failed with error: $error', MessageType.error);
      _logger.severe('Search failed with unhandled error.  Contact the dev!');
      return;
    }

    if (sunCoords.isNotEmpty) {
      _sunLocations.addAll(sunCoords);
      _logger.info('Search found ${sunCoords.length} sun locations.');
    } else {
      return returnSunLocations(radiusKilometers + 100);
    }

    _isSearching = false;
    notifyListeners();
  }

  bool isItNight() {
    /// Determine if it is after sunset or before sunrise at
    /// the start location using the Sunrise/Sunset Algorithm.

    DateTime now = DateTime.now().toUtc();
    double zenith = 92; // Zenith for official sunrise/sunset

    double toDegrees(double radian) {
      return radian * (180 / pi);
    }

    double toRadians(double degree) {
      return degree * (pi / 180);
    }

    double adjustToRange(double value, double max) {
      if (value < 0) {
        value += max;
      }
      if (value > max) {
        value -= max;
      }
      return value;
    }

    DateTime convertToDate(
      double time,
      double currentTime,
      double rightAscensionDeg,
      double lngHour,
    ) {
      /// Convert a given time in hour within a 24 hour period
      /// to a datetime object, adjusting for UTC midnight rollover.

      // Calculate local mean time of rising and setting
      double localMeanTime =
          time + rightAscensionDeg - (0.06571 * currentTime) - 6.622;

      // Convert to hours
      localMeanTime -= lngHour;
      localMeanTime = adjustToRange(localMeanTime, 24);

      // Convert to DateTime
      // Duration offset = now.timeZoneOffset;
      int hour = localMeanTime.floor();
      int minute = ((localMeanTime - hour) * 60).floor();
      DateTime result = DateTime.utc(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Adjust for UTC midnight rollover
      if (result.isBefore(now.subtract(Duration(hours: 12)))) {
        result = result.add(Duration(days: 1));
      } else if (result.isAfter(now.add(Duration(hours: 12)))) {
        result = result.subtract(Duration(days: 1));
      }

      return result;
    }

    // Calculate the day of the year
    final startOfYear = DateTime.utc(now.year, 1, 1);
    final currentDayNumber = now.difference(startOfYear).inDays + 1;

    // Calculate longitude hour and current time
    double lngHour = _startPoint.longitude / 15.0;
    double currentTime = currentDayNumber + ((18 - lngHour) / 24);

    // Calculate Sun's mean anomaly
    double anomalyDeg = (0.9856 * currentTime) - 3.289;

    // Calculate Sun's true longitude and correct to be in range [0,360]
    double trueLongitudeDeg =
        anomalyDeg +
        (1.916 * sin(toRadians(anomalyDeg))) +
        (0.020 * sin(2 * toRadians(anomalyDeg))) +
        282.634;
    trueLongitudeDeg = adjustToRange(trueLongitudeDeg, 360);

    // Calculate Sun's right ascension and correct to be in range [0,360]
    double rightAscensionDeg = toDegrees(
      atan(0.91764 * tan(toRadians(trueLongitudeDeg))),
    );
    rightAscensionDeg = adjustToRange(rightAscensionDeg, 360);

    // Right ascension value needs to be in the same quadrant as the trueLongitude
    double lQuadrant = (trueLongitudeDeg / 90).floor() * 90;
    double raQuadrant = (rightAscensionDeg / 90).floor() * 90;
    rightAscensionDeg += (lQuadrant - raQuadrant);

    // Right ascension needs to be in hours
    rightAscensionDeg = rightAscensionDeg / 15;

    //Calculate Sun's declination
    double sinDec = 0.39782 * sin(toRadians(trueLongitudeDeg));
    double cosDec = cos(asin(sinDec));

    // Calculate Sun's local hour angle
    double zenithRad = toRadians(zenith);
    double cosLocalHour =
        (cos(zenithRad) - (sinDec * sin(toRadians(_startPoint.latitude)))) /
        (cosDec * cos(toRadians(_startPoint.latitude)));
    if (cosLocalHour > 1) {
      return true;
    }
    if (cosLocalHour < -1) {
      return false;
    }

    // Calculate rising and setting time
    double risingTime = (360 - toDegrees(acos(cosLocalHour))) / 15;
    double settingTime = toDegrees(acos(cosLocalHour)) / 15;

    DateTime risingDateTime = convertToDate(
      risingTime,
      currentTime,
      rightAscensionDeg,
      lngHour,
    );
    DateTime settingDateTime = convertToDate(
      settingTime,
      currentTime,
      rightAscensionDeg,
      lngHour,
    );

    if (now.isBefore(risingDateTime) || now.isAfter(settingDateTime.toUtc())) {
      return true;
    } else {
      return false;
    }
  }
}
