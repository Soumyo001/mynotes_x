import 'package:flutter/material.dart';
import 'package:mynotes_x/components/check_box_text_field.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Row(
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
            child: TextFieldForCheckBox(
              controller:
                  widget.favourite['controller'] as TextEditingController,
              hintText: 'Enter item',
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
            value: widget.favourite['isChecked'] as bool,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
