import 'package:flutter/material.dart';
import 'package:mynotes_x/utilities/generics/generic_dialog.dart';

Future<void> showInfoDialog(BuildContext context, String title, String text) {
  return showGenericDialog<void>(
    context: context,
    title: title,
    content: text,
    dialogOptionBuilder: () => {
      'OK': null,
    },
  );
}
