import 'package:flutter/material.dart';

class AlterDialogContentButton extends StatelessWidget {
  final String buttonText;
  final void Function()? onPressed;
  const AlterDialogContentButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 10,
          foregroundColor: Theme.of(context).colorScheme.secondary,
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
    );
  }
}
