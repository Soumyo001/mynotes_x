import 'package:flutter/material.dart';
import 'package:mynotes_x/utilities/generics/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Share',
    content: 'You cannot share an empty note!',
    dialogOptionBuilder: () => {
      'OK': null,
    },
  );
}
