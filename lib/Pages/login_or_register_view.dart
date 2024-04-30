import 'package:flutter/material.dart';
import 'package:mynotes/Pages/login_view.dart';
import 'package:mynotes/Pages/registration_view.dart';

class LoginOrRegisterView extends StatefulWidget {
  const LoginOrRegisterView({super.key});

  @override
  State<LoginOrRegisterView> createState() => _LoginOrRegisterViewState();
}

class _LoginOrRegisterViewState extends State<LoginOrRegisterView> {
  bool showLoginView = true;

  void toggleView() {
    setState(() {
      showLoginView = !showLoginView;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginView) {
      return LoginView(onTap: toggleView);
    } else {
      return RegisterView(onTap: toggleView);
    }
  }
}
