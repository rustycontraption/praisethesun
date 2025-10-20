import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:praisethesun/src/markers.dart';
// import 'widgets/find_sun_button.dart';

class SunLocationModel extends ChangeNotifier {
  final String sunAPIUrl = 'http://10.0.2.2:8000/sun/';
  final List<Marker> _markers = [];
  final int startMarkerIndex = 0;
  final int sunMarkerIndex = 1;
  late LatLngBounds _bounds;
  LatLng? _sunLocation;
  LatLng _startPoint = LatLng(47.60621, -122.33207);

  SunLocationModel() {
    _bounds = LatLngBounds.fromPoints([
      Distance().offset(_startPoint, 1000, 225),
      Distance().offset(_startPoint, 1000, 45),
    ]);
    _markers.add(startLocationMarker(_startPoint));
  }

  LatLng? get sunLocation => _sunLocation;
  LatLng get startPoint => _startPoint;
  LatLngBounds get bounds => _bounds;
  List<Marker> get markers => _markers;

  Future<void> getSunLocationFromServer() async {
    late http.Response response;
    final uri = Uri.parse(
      '$sunAPIUrl?start_point_lat=${_startPoint.latitude}&start_point_lng=${_startPoint.longitude}',
    );
    try {
      response = await http.get(uri);
    } catch (error) {
      throw error;
    }

    if (response.statusCode != 200) {
      throw ('Failed to update resource');
    }

    final jsonResponse = jsonDecode(response.body);
    List<LatLng> sunCoords = (jsonResponse['data'] as List).map((item) {
      return LatLng(item['lat'], item['lng']);
    }).toList();
    _sunLocation = sunCoords.isNotEmpty ? sunCoords[0] : null;
    _updateMarker(sunMarkerIndex, _sunLocation!, sunLocationMarker);
    notifyListeners();
  }

  void setStartPoint(LatLng newStartPoint) {
    _startPoint = newStartPoint;
    markers[startMarkerIndex] = startLocationMarker(newStartPoint);
    notifyListeners();
  }

  void _updateMarker(
    int index,
    LatLng newPoint,
    Marker Function(LatLng) markerBuilder,
  ) {
    if (!markers.asMap().containsKey(index)) {
      markers.add(markerBuilder(newPoint));
    } else {
      markers[index] = markerBuilder(newPoint);
    }
  }
}
