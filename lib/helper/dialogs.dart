import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
