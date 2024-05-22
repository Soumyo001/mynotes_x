import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/home_view.dart';
import 'package:mynotes_x/Pages/login_or_register_view.dart';
import 'package:mynotes_x/Pages/verify_email.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/auth/auth_user.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthUser?>(
        stream: AuthService.firebase().onUserChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (AuthService.firebase().currentUser!.isEmailVerified) {
              return const HomePage();
            } else {
              return const VerifyEmail();
            }
          } else {
            return const LoginOrRegisterView();
          }
        },
      ),
    );
  }
}
