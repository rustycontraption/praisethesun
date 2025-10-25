import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    ),
  );
}

void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      duration: const Duration(seconds: 10),
    ),
  );
}
