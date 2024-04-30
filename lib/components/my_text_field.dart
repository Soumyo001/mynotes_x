import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool autoCorrect, enableSuggestions, obscureText;
  final String hintText;
  final TextInputType? type;
  final double horizontalPadding;
  final double verticalPadding;

  const MyTextField({
    super.key,
    required this.controller,
    required this.autoCorrect,
    required this.enableSuggestions,
    required this.obscureText,
    required this.hintText,
    required this.horizontalPadding,
    required this.verticalPadding,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: TextField(
        controller: controller,
        autocorrect: autoCorrect,
        obscureText: obscureText,
        enableSuggestions: enableSuggestions,
        keyboardType: type,
        cursorColor: Colors.grey.shade600,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
