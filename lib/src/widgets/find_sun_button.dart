import 'package:flutter/material.dart';
import 'package:praisethesun/src/model.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:praisethesun/src/model.dart';
// import 'package:provider/provider.dart';

class FindSunButton extends StatefulWidget {
  const FindSunButton({super.key});

  @override
  State<FindSunButton> createState() => _FindSunButtonState();
}

class _FindSunButtonState extends State<FindSunButton> {
  bool _isLoading = false;

  void _updateCameraLocation() {
    // final sunModel = Provider.of<SunLocationModel>(context);
    // final mapController = MapController.of(context);
    // LatLngBounds newBounds;
    // if (sunModel.sunLocation != null) {
    //   newBounds = LatLngBounds.fromPoints([
    //     sunModel.startPoint,
    //     sunModel.sunLocation!,
    //   ]);
    //   mapController.fitCamera(
    //     CameraFit.bounds(bounds: newBounds, padding: EdgeInsets.all(100)),
    //   );
    //   mapController.rotate(0);
    // }
    print("update camera location");
  }

  Future<void> _handleSun(BuildContext context) async {
    final sunModel = context.read<SunLocationModel>();

    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));

    await sunModel.getSunLocationFromServer();
    // _updateCameraLocation();

    setState(() {
      _isLoading = false;
    });
    print(context.read<SunLocationModel>().sunLocation);
    print("handle sun");
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 48,
      padding: EdgeInsets.zero,
      onPressed: _isLoading ? null : () => _handleSun(context),
      icon: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.search),
            if (_isLoading)
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(color: Colors.orange),
              ),
          ],
        ),
      ),
      style: IconButton.styleFrom(foregroundColor: Colors.orange),
    );
  }
}
