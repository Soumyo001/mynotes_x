import 'package:flutter/cupertino.dart';
import 'package:mynotes_x/utilities/generics/generic_dialog.dart';

Future<bool> showDeleteDialog({
  required BuildContext context,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete?',
    dialogOptionBuilder: () => {
      'Yes': true,
      'No': false,
    },
  ).then((value) => value ?? false);
}
