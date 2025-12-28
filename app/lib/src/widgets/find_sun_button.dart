import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/model.dart';

class FindSunButton extends StatefulWidget {
  const FindSunButton({super.key});

  @override
  State<FindSunButton> createState() => _FindSunButtonState();
}

class _FindSunButtonState extends State<FindSunButton> {
  static const double _buttonSize = 80.0;
  static const double _iconSize = 48.0;
  static const double _loadingIndicatorSize = _buttonSize * 0.65;

  @override
  Widget build(BuildContext context) {
    final sunModel = context.read<SunLocationModel>();
    final Color buttonColor = sunModel.isItNight()
        ? Colors.lightBlue
        : Colors.orange;
    return IconButton(
      iconSize: _iconSize,
      padding: EdgeInsets.zero,
      onPressed: sunModel.isSearching
          ? sunModel.stopSearch
          : () async => await sunModel.returnSunLocations(),
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.location_searching, color: buttonColor, size: _buttonSize),
          Container(
            width: _loadingIndicatorSize,
            height: _loadingIndicatorSize,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(sunModel.isSearching ? Icons.close : Icons.search),
                if (sunModel.isSearching)
                  SizedBox(
                    width: _buttonSize,
                    height: _buttonSize,
                    child: CircularProgressIndicator(color: buttonColor),
                  ),
              ],
            ),
          ),
        ],
      ),
      style: IconButton.styleFrom(foregroundColor: buttonColor),
    );
  }
}
