import 'package:flutter/material.dart';
import 'package:mynotes_x/utilities/generics/generic_dialog.dart';

Future<bool> showLogoutDialog({
  required BuildContext context,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Logout',
    content: 'Are you sure you want to logout?',
    dialogOptionBuilder: () => {
      'Logout': true,
      'Cancel': false,
    },
  ).then((value) => value ?? false);
}
