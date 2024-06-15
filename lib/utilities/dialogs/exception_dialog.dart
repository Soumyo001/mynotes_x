import 'package:flutter/material.dart';
import 'package:mynotes_x/utilities/generics/generic_dialog.dart';

Future<void> showExceptionDialog({
  required String title,
  required String content,
  required BuildContext context,
}) {
  return showGenericDialog<void>(
    context: context,
    title: title,
    content: content,
    dialogOptionBuilder: () => {
      'OK': null,
    },
  );
}
