import 'package:flutter/material.dart';

class TextWithCheckBox extends StatefulWidget {
  final Map<dynamic, dynamic> value;
  final void Function(bool?)? onChanged;
  final String index;
  final String? secondaryIndex;
  final bool icon;
  const TextWithCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.index,
    this.secondaryIndex,
    required this.icon,
  });

  @override
  State<TextWithCheckBox> createState() => _TextWithCheckBoxState();
}

class _TextWithCheckBoxState extends State<TextWithCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (widget.icon
            ? Icon(
                Icons.tag_rounded,
                color: Theme.of(context).colorScheme.secondary,
              )
            : const SizedBox(
                width: 0,
              )),
        Expanded(
          child: Text(
            maxLines: null,
            widget.value[widget.index]! as String,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
        Checkbox(
          splashRadius: 25,
          activeColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          checkColor: Theme.of(context).colorScheme.primary,
          value: widget.value[widget.secondaryIndex ?? 'isChecked'] as bool?,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
