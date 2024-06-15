// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:mynotes_x/themes/theme_provider.dart';
import 'package:mynotes_x/utilities/dialogs/delete_account_dialog.dart';
import 'package:mynotes_x/utilities/dialogs/info_dialog.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  final int userid;
  const Settings({
    super.key,
    required this.userid,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final NotesService _notesService;

  Future<void> accountDeletion() async {
    await _notesService.deleteAllTags(widget.userid);
    await _notesService.deleteAllNote(widget.userid);
    await AuthService.firebase().deleteAccount();
  }

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'S E T T I N G S',
        ),
        foregroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 21.0,
            top: 16,
            right: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Settings',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Divider(
                thickness: 0.5,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(
                height: 10,
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final shouldDelete = await showDeleteAccountDialog(context);

                  if (shouldDelete) {
                    try {
                      await accountDeletion().then((value) {
                        Navigator.of(context).pop();
                      });
                    } on CouldNotDeleteAccountException {
                      await showInfoDialog(context, 'Error Deleting Account',
                          'You might need to re-login or re-create your account');
                    } catch (e) {
                      await showInfoDialog(
                          context, 'Error Deleting Account', e.toString());
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 23,
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              Text(
                'Theme Settings',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Divider(
                thickness: 0.5,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15.5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.dark_mode,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Dark Theme',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 17.5,
                          ),
                        ),
                      ],
                    ),
                    CupertinoSwitch(
                      value: Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).isDarkMode,
                      onChanged: (value) =>
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
