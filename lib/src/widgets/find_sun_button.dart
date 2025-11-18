import 'dart:async';

import 'package:flutter/material.dart';
import 'package:praisethesun/src/model/model.dart';
import 'package:praisethesun/src/widgets/snackbar_message.dart';
import 'package:provider/provider.dart';

class FindSunButton extends StatefulWidget {
  const FindSunButton({super.key});

  @override
  State<FindSunButton> createState() => _FindSunButtonState();
}

class _FindSunButtonState extends State<FindSunButton> {
  static const double _buttonSize = 80.0;
  static const double _iconSize = 48.0;
  static const double _loadingIndicatorSize = _buttonSize * 0.65;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleSun() async {
    final sunModel = context.read<SunLocationModel>();

    setState(() {
      _isLoading = true;
    });

    try {
      await sunModel.returnSunLocations();
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.toString());
      }
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelSearch() {
    final sunModel = context.read<SunLocationModel>();
    sunModel.cancelSearch();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: _iconSize,
      padding: EdgeInsets.zero,
      onPressed: _isLoading ? _cancelSearch : () => _handleSun(),
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.location_searching,
            color: Colors.orange,
            size: _buttonSize,
          ),
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
                Icon(_isLoading ? Icons.close : Icons.search),
                if (_isLoading)
                  const SizedBox(
                    width: _buttonSize,
                    height: _buttonSize,
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
              ],
            ),
          ),
        ],
      ),
      style: IconButton.styleFrom(foregroundColor: Colors.orange),
    );
  }
}
