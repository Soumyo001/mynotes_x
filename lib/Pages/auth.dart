import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/home_view.dart';
import 'package:mynotes_x/Pages/login_or_register_view.dart';
import 'package:mynotes_x/Pages/verify_email.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/auth/auth_user.dart';
import 'package:mynotes_x/services/notification_services/notification_service.dart';
import 'dart:developer' as dev;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  void onClickedNotification(String? payload) async {
    if (AuthService.firebase().currentUser == null) {
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   loginRoute,
      //   (route) => false,
      // );
    } else {
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) {
      //     return HomePage(
      //       payload: payload,
      //     );
      //   }),
      //   (route) => false,
      // );
    }
  }

  void listenToNotifications() {
    NotificationService.getInstance()
        .onClick
        .stream
        .listen(onClickedNotification);
  }

  @override
  void initState() {
    listenToNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthUser?>(
        stream: AuthService.firebase().onUserChanges(),
        builder: (context, snapshot) {
          dev.log('entered stream builder');
          if (snapshot.hasData) {
            if (AuthService.firebase().currentUser!.isEmailVerified) {
              return const HomePage();
            } else {
              return const VerifyEmail();
            }
          } else {
            dev.log('entered the else part in the stream builder');
            return const LoginOrRegisterView();
          }
        },
      ),
    );
  }
}
