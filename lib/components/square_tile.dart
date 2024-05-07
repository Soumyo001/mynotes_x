import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String path;
  final Function()? onTap;
  const SquareTile({super.key, required this.path, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Image.asset(
          path,
          height: 40,
        ),
      ),
    );
  }
}
