import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/services/sun_logging.dart';

class SunApiClient {
  final Logger _logger = SunLogging.getLogger('SunApiClient');
  final Dio dio;
  final String sunAPIUrl = 'http://10.0.2.2:8000/sun/';

  SunApiClient({Dio? dioInstance})
    : dio =
          dioInstance ??
          Dio(
            BaseOptions(
              connectTimeout: Duration(seconds: 5),
              receiveTimeout: Duration(seconds: 5),
            ),
          );

  Future<List<LatLng>> getSunLocationFromServer({
    required LatLng startPoint,
    required CancelToken cancelToken,
    required int radiusKilometers,
  }) async {
    Response response;

    final uri = Uri.parse(sunAPIUrl).replace(
      queryParameters: {
        'start_point_lat': startPoint.latitude.toString(),
        'start_point_lng': startPoint.longitude.toString(),
        'radiusKilometers': radiusKilometers.toString(),
      },
    );

    response = await dio.getUri(uri, cancelToken: cancelToken);

    if (response.statusCode == 200) {
      return (response.data['data']['sun_location'] as List).map((item) {
        return LatLng(item['lat'], item['lng']);
      }).toList();
    } else {
      _logger.severe(
        'Failed to fetch sun locations: HTTP ${response.statusCode}',
      );
      throw Exception(
        'Sun data API returned HTTP code: ${response.statusCode}',
      );
    }
  }
}
