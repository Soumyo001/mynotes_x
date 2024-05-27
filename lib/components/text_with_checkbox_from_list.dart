import 'package:flutter/material.dart';

class TextWithCheckBox extends StatefulWidget {
  final Map<dynamic, dynamic> value;
  final void Function(bool?)? onChanged;
  final String index;
  final String? secondaryIndex;
  final bool isMainIndexController;
  final bool icon;
  final TextDecoration? textDecoration;
  final double? fontSize;
  final double? textLeftPadding;
  const TextWithCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.index,
    this.secondaryIndex,
    this.textDecoration,
    this.fontSize,
    required this.icon,
    required this.isMainIndexController,
    required this.textLeftPadding,
  });

  @override
  State<TextWithCheckBox> createState() => _TextWithCheckBoxState();
}

class _TextWithCheckBoxState extends State<TextWithCheckBox> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 40,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (widget.icon
              ? Icon(
                  Icons.tag_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                )
              : SizedBox(
                  width: widget.textLeftPadding,
                )),
          Expanded(
            child: Text(
              (widget.isMainIndexController
                  ? (widget.value[widget.index] as TextEditingController).text
                  : widget.value[widget.index]! as String),
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: widget.fontSize,
                decoration: widget.textDecoration,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
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
      ),
    );
  }
}
