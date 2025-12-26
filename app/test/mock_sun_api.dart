import 'dart:async';

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/model/sun_api_client.dart';
import 'mock_data.dart';

enum MockFailureType { none, networkError, serverError, timeout }

class MockSunApiClient extends SunApiClient {
  Completer<List<LatLng>>? _searchCompleter;

  bool get hasActivePendingSearch =>
      _searchCompleter != null && !_searchCompleter!.isCompleted;

  void cancelPendingSearch() {
    _searchCompleter = null;
  }

  void completePendingSearch({bool returnData = false}) {
    if (_searchCompleter != null && !_searchCompleter!.isCompleted) {
      if (returnData) {
        _searchCompleter!.complete(mockData['mockSunLocations']);
      } else {
        _searchCompleter!.complete(<LatLng>[]);
      }
      _searchCompleter = null;
    }
  }

  void completeWithError(MockFailureType failureType) {
    if (_searchCompleter != null && !_searchCompleter!.isCompleted) {
      Object error;
      switch (failureType) {
        case MockFailureType.networkError:
          error = DioException(
            requestOptions: RequestOptions(path: sunAPIUrl),
            type: DioExceptionType.connectionTimeout,
          );
          break;
        case MockFailureType.serverError:
          error = Exception('Server returned 500');
          break;
        case MockFailureType.timeout:
          error = TimeoutException('Request timed out');
          break;
        case MockFailureType.none:
          return;
      }
      _searchCompleter!.completeError(error);
      _searchCompleter = null;
    }
  }

  @override
  Future<List<LatLng>> getSunLocationFromServer({
    required LatLng startPoint,
    required CancelToken cancelToken,
    required int radiusKilometers,
  }) async {
    _searchCompleter = Completer<List<LatLng>>();

    if (!cancelToken.isCancelled) {
      cancelToken.whenCancel.then((_) {
        if (_searchCompleter != null && !_searchCompleter!.isCompleted) {
          _searchCompleter!.completeError(
            DioException(
              requestOptions: RequestOptions(path: sunAPIUrl),
              type: DioExceptionType.cancel,
            ),
          );
          _searchCompleter = null;
        }
      });
    }

    return _searchCompleter!.future;
  }
}
