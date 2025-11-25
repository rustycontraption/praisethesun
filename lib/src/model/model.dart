import 'dart:async';
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

  void resetSearch() {
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
      resetSearch();
      _infoMessage =
          'No sun locations found within a $_maxSearchRadius km radius.';
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
      resetSearch();
      switch (error.type) {
        case DioExceptionType.cancel:
          setSystemMessage('Search cancelled by user.', MessageType.info);
          _logger.info('Search cancelled by user.');
        case DioExceptionType.connectionTimeout:
          setSystemMessage('Search timed out. Try again!', MessageType.error);
          _logger.severe('Connection timed out during search.');
        case DioExceptionType.receiveTimeout:
          setSystemMessage('Search timed out. Try again!', MessageType.error);
          _logger.severe('Receive timed out during search.');
        case DioExceptionType.sendTimeout:
          setSystemMessage('Search timed out. Try again!', MessageType.error);
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
      resetSearch();
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
}
