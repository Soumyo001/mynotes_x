import 'package:flutter/material.dart';

Future<bool> showErrorDialog({
  required BuildContext context,
  required String messege,
}) {
  return showDialog<bool>(
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
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.black87),
            ),
          )
        ],
      );
    },
  ).then((value) => value ?? true);
}
