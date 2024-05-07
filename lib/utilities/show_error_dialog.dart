import 'package:flutter/material.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String messege,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: const Icon(
          Icons.error,
          color: Colors.black87,
        ),
        title: Text(
          messege,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.black87),
            ),
          )
        ],
      );
    },
  );
}
