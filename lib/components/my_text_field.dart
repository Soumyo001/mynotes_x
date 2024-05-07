import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool autoCorrect, enableSuggestions, obscureText;
  final String hintText;
  final TextInputType? keyboardType;
  final double horizontalPadding;
  final double verticalPadding;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String value)? onChanged;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final TextStyle? errorStyle;

  const MyTextField({
    super.key,
    required this.controller,
    required this.autoCorrect,
    required this.enableSuggestions,
    required this.obscureText,
    required this.hintText,
    required this.horizontalPadding,
    required this.verticalPadding,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.errorText,
    this.errorBorder,
    this.focusedErrorBorder,
    this.errorStyle,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.horizontalPadding,
        vertical: widget.verticalPadding,
      ),
      child: TextField(
        onChanged: widget.onChanged,
        controller: widget.controller,
        autocorrect: widget.autoCorrect,
        obscureText: widget.obscureText,
        enableSuggestions: widget.enableSuggestions,
        keyboardType: widget.keyboardType,
        cursorColor: Colors.grey.shade600,
        decoration: InputDecoration(
          errorText: widget.errorText,
          errorStyle: widget.errorStyle,
          errorBorder: widget.errorBorder,
          focusedErrorBorder: widget.focusedErrorBorder,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
