import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../services/sun_logging.dart';

class SunApiClient {
  final Logger _logger = SunLogging.getLogger('SunApiClient');
  final Dio dio;
  final String sunAPIUrl = const String.fromEnvironment('SUN_API_URL');
  final String apiKey = const String.fromEnvironment('SUN_API_KEY');

  SunApiClient({Dio? dioInstance})
    : dio =
          dioInstance ??
          Dio(
            BaseOptions(
              connectTimeout: Duration(seconds: 2),
              sendTimeout: Duration(seconds: 2),
              receiveTimeout: Duration(seconds: 30),
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

    response = await dio.getUri(
      uri,
      cancelToken: cancelToken,
      options: Options(headers: {'x-api-key': apiKey}),
    );

    if (response.statusCode == 200) {
      return (response.data as List).map((item) {
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
