import 'package:flutter/material.dart';

Future<void> showErrorDialog(
    BuildContext context, String title, String message) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26),
        ),
        content: Text(message),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      );
    },
  );
}
