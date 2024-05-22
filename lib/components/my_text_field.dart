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
  final int? maxLines;
  final TextStyle? textInputStyle;

  const MyTextField({
    super.key,
    required this.controller,
    required this.autoCorrect,
    required this.enableSuggestions,
    required this.obscureText,
    required this.hintText,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.maxLines,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.errorText,
    this.errorBorder,
    this.focusedErrorBorder,
    this.errorStyle,
    this.textInputStyle,
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
        style: widget.textInputStyle,
        onChanged: widget.onChanged,
        controller: widget.controller,
        autocorrect: widget.autoCorrect,
        maxLines: widget.maxLines,
        obscureText: widget.obscureText,
        enableSuggestions: widget.enableSuggestions,
        keyboardType: widget.keyboardType,
        cursorColor: Theme.of(context).colorScheme.inversePrimary,
        cursorWidth: 1.0,
        decoration: InputDecoration(
          errorText: widget.errorText,
          errorStyle: widget.errorStyle,
          errorBorder: widget.errorBorder,
          focusedErrorBorder: widget.focusedErrorBorder,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.secondary),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          fillColor: Theme.of(context).colorScheme.primary,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
