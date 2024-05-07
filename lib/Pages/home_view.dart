import 'package:flutter/material.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/facebook_auth/facebook_auth_service.dart';
import 'package:mynotes_x/services/google_auth/google_auth_service.dart';
import 'package:mynotes_x/utilities/show_error_dialog.dart';

enum MenuActions { logout }

class HomePage extends StatelessWidget {
  final user = AuthService.firebase().currentUser;

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        actions: [
          PopupMenuButton<MenuActions>(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onSelected: (value) async {
              switch (value) {
                case MenuActions.logout:
                  if (await showLogoutDialog(context)) {
                    try {
                      await AuthService.firebase().logOut();
                      await GAuthService.firebase().signOut();
                      await FAuthService.firebase().logOut();
                    } on UserNotLoggedInException catch (e) {
                      await showErrorDialog(
                        context: context,
                        messege: e.code,
                      );
                    } catch (e) {
                      await showErrorDialog(
                        context: context,
                        messege:
                            'Not from own class exception: ${e.toString()}',
                      );
                    }
                  }
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuActions>(
                  padding: EdgeInsets.all(10.0),
                  value: MenuActions.logout,
                  child: Text(
                    'Log out',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Logged in as : ${user!.email}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.black87),
        ),
        content: const Text(
          'Are you sure you want to logout ?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          MaterialButton(
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.black87),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          MaterialButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black87),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
