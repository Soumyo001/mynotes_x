import 'package:flutter/material.dart';
import 'package:mynotes_x/utilities/generics/generic_dialog.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) async {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete Account',
    content:
        'Are you sure you want to delete your account? This action is irreversible.',
    dialogOptionBuilder: () => {
      'Yes': true,
      'No': false,
    },
  ).then((value) => value ?? false);
}
