import 'package:flutter/material.dart';

class TextFieldForCheckBox extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  const TextFieldForCheckBox({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  State<TextFieldForCheckBox> createState() => _TextFieldForCheckBoxState();
}

class _TextFieldForCheckBoxState extends State<TextFieldForCheckBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: widget.controller!,
        decoration: const InputDecoration(
          hintText: 'Enter item',
          hintStyle: TextStyle(
            fontWeight: FontWeight.w300,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 0,
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 0,
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
