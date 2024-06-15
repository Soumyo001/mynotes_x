// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/password_reset.dart';
import 'package:mynotes_x/components/my_button.dart';
import 'package:mynotes_x/components/my_text_field.dart';
import 'package:mynotes_x/components/square_tile.dart';
import 'package:mynotes_x/helpers/loading/loading_screen.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/facebook_auth/facebook_auth_service.dart';
import 'package:mynotes_x/services/google_auth/google_auth_service.dart';
import 'package:mynotes_x/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  final void Function()? onTap;
  const LoginView({super.key, this.onTap});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool obscureText = true;

  signInWithEmailAndPassword() async {
    LoadingScreen().show(context: context, text: 'Loading...');
    try {
      await AuthService.firebase()
          .logIn(email: _email.text, password: _password.text);

      LoadingScreen().hide();
    } on UserNotLoggedInException catch (e) {
      LoadingScreen().hide();
      await showErrorDialog(context: context, messege: e.code);
    } on GenericException catch (e) {
      LoadingScreen().hide();
      await showErrorDialog(context: context, messege: e.code);
    } catch (e) {
      LoadingScreen().hide();
      await showErrorDialog(
          context: context,
          messege: 'Not from own class exceptions: ${e.toString()}');
    }
  }

  signInWithGoogle() async {
    LoadingScreen().show(context: context, text: 'Loading...');
    try {
      await GAuthService.firebase().signIn();

      LoadingScreen().hide();
    } on NoEmailChoosenException {
      LoadingScreen().hide();
      return;
    } on UserNotLoggedInException catch (e) {
      LoadingScreen().hide();
      await showErrorDialog(context: context, messege: e.code);
    } on GenericException catch (e) {
      LoadingScreen().hide();
      await showErrorDialog(context: context, messege: e.code);
    } catch (e) {
      LoadingScreen().hide();
      await showErrorDialog(
          context: context,
          messege: 'not from own class exceptions: ${e.toString()}');
    }
  }

  void signInWithFacebook() async {
    try {
      await FAuthService.firebase().logIn();
    } on NoAccountChoosenException {
      return;
    } on GenericException catch (e) {
      await showErrorDialog(context: context, messege: e.code);
    } catch (e) {
      await showErrorDialog(
          context: context,
          messege: 'not from own class exceptions: ${e.toString()}');
    }
  }

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        // SafeArea(child : Center(child : Column(children)))
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Icon
                Icon(
                  Icons.lock,
                  size: 85,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),

                const SizedBox(height: 15),

                Text(
                  'User Login',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                //text_field email
                MyTextField(
                  controller: _email,
                  autoCorrect: false,
                  enableSuggestions: false,
                  obscureText: false,
                  hintText: 'E-mail',
                  keyboardType: TextInputType.emailAddress,
                  horizontalPadding: 25.0,
                  verticalPadding: 0.0,
                  maxLines: 1,
                ),

                const SizedBox(
                  height: 10,
                ),

                //text_field password
                MyTextField(
                  controller: _password,
                  autoCorrect: false,
                  enableSuggestions: false,
                  obscureText: obscureText,
                  hintText: 'Password',
                  horizontalPadding: 25.0,
                  verticalPadding: 0.0,
                  maxLines: 1,
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    child: Icon(
                      (obscureText ? Icons.visibility : Icons.visibility_off),
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (_email.text.isNotEmpty) {
                            AuthService.firebase()
                                .sendPasswordResetEmail(_email.text);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PasswordResetView(),
                              ),
                            );
                          } else {
                            showErrorDialog(
                                context: context,
                                messege: 'Email field is empty');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: Text(
                            'forgot password?',
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                //text_button for register
                MyButton(
                  onTap: signInWithEmailAndPassword,
                  buttonText: "Login",
                ),

                const SizedBox(
                  height: 50,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 35,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      path: 'lib/images/google_icon.png',
                      onTap: signInWithGoogle,
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    SquareTile(
                      path: 'lib/images/facebook_icon.png',
                      onTap: signInWithFacebook,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 40,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'not a member?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register Now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
