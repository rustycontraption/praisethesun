// import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SunLocationModel extends ChangeNotifier {
  LatLng? _sunLocation;
  LatLng _startPoint = LatLng(47.60621, -122.33207);
  late LatLngBounds _bounds;

  SunLocationModel() {
    _bounds = LatLngBounds.fromPoints([
      Distance().offset(_startPoint, 1000, 225),
      Distance().offset(_startPoint, 1000, 45),
    ]);
  }
  LatLng? get sunLocation => _sunLocation;
  LatLng get startPoint => _startPoint;
  LatLngBounds get bounds => _bounds;

  void getSunLocationFromServer() async {
    // final uri = Uri.parse('https://myapi.com/sunLocation');
    // final response = await get(uri);

    // if (response.statusCode != 200) {
    //   throw ('Failed to update resource');
    // }
    _sunLocation = LatLng(46.726444, -120.153528);
    updateCameraBounds(_sunLocation!);
    notifyListeners();
  }

  void setStartPoint(LatLng newStartPoint) {
    _startPoint = newStartPoint;
    notifyListeners();
  }

  void updateCameraBounds(LatLng boundCenter) {
    final swBound = Distance().offset(boundCenter, 1000, 225);
    final neBound = Distance().offset(boundCenter, 1000, 45);
    _bounds = LatLngBounds.fromPoints([swBound, neBound]);
  }
}
