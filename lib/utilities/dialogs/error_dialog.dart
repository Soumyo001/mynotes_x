import 'package:flutter/material.dart';
import 'package:mynotes_x/utilities/generics/generic_dialog.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String messege,
}) {
  return showGenericDialog<void>(
    context: context,
    title: 'An Error Occured',
    content: messege,
    dialogOptionBuilder: () => {
      'OK': null,
    },
  );
}
