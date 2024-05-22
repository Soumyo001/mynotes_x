import 'package:flutter/material.dart';

class AllNotes extends StatelessWidget {
  final String email;
  final String? payload;
  const AllNotes({
    super.key,
    required this.email,
    this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'Logged in as: $payload',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
      ],
    );
  }
}
