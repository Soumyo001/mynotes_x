import 'package:flutter/material.dart';
import 'package:mynotes_x/utilities/constants.dart';

class TextFieldCheckBox extends StatefulWidget {
  final Map<dynamic, dynamic> favourite;
  final void Function()? onPressed;
  final void Function(bool?)? onChanged;
  const TextFieldCheckBox({
    super.key,
    required this.favourite,
    required this.onPressed,
    required this.onChanged,
  });

  @override
  State<TextFieldCheckBox> createState() => _TextFieldCheckBoxState();
}

class _TextFieldCheckBoxState extends State<TextFieldCheckBox> {
  TextEditingController get textController => widget.favourite['controller'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: widget.onPressed,
          icon: Icon(
            Icons.remove_circle_sharp,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.multiline,
            controller:
                widget.favourite[controllerTag] as TextEditingController,
            style: const TextStyle(
              fontSize: 14.3,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter item',
              hintStyle: TextStyle(
                fontWeight: FontWeight.w300,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Checkbox(
          splashRadius: 20,
          activeColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          checkColor: Theme.of(context).colorScheme.primary,
          value: widget.favourite[checkedTag] as bool,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

            // child: TextFieldForCheckBox(
            //   controller:
            //       widget.favourite['controller'] as TextEditingController,
            //   hintText: 'Enter item',
            // ),