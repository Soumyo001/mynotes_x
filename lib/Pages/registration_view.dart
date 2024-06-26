// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mynotes_x/components/my_button.dart';
import 'package:mynotes_x/components/my_text_field.dart';
import 'package:mynotes_x/components/square_tile.dart';
import 'package:mynotes_x/helpers/loading/loading_screen.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/facebook_auth/facebook_auth_service.dart';
import 'package:mynotes_x/services/google_auth/google_auth_service.dart';
import 'package:mynotes_x/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  final void Function()? onTap;
  const RegisterView({super.key, this.onTap});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  TextStyle? errorTextStyle = const TextStyle();
  TextStyle? errorTextStyleC = const TextStyle();
  TextStyle? errorTextStyleEmail = const TextStyle();
  InputBorder? errorBorder = const OutlineInputBorder();
  InputBorder? errorBorderC = const OutlineInputBorder();
  InputBorder? errorBorderEmail = const OutlineInputBorder();
  InputBorder? errorFocusedBorder = const OutlineInputBorder();
  InputBorder? errorFocusedBorderC = const OutlineInputBorder();
  InputBorder? errorFocusedBorderEmail = const OutlineInputBorder();
  final RegExp passPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$',
    caseSensitive: false,
    multiLine: false,
  );
  final RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  bool obscureText = true;
  bool obscureConfirmText = true;
  String errorText = '';
  String errorTextC = '';
  String errorTextEmail = '';

  void signUpWithEmailAndPassword() async {
    LoadingScreen().show(context: context, text: 'Loading...');
    try {
      await AuthService.firebase().createUser(
        email: _email.text,
        password: _password.text,
        confirmPassword: _confirmPassword.text,
        emailPattern: emailPattern,
        passPattern: passPattern,
      );
      LoadingScreen().hide();
      final user = AuthService.firebase().currentUser;
      if (user != null) {
        await AuthService.firebase().reload();
        if (!user.isEmailVerified) {
          await AuthService.firebase().sendEmailverification();
        }
      }
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

  void signUpWithGoogle() async {
    LoadingScreen().show(context: context, text: 'Loading...');
    try {
      await GAuthService.firebase().signUp();
      LoadingScreen().hide();
      final user = GAuthService.firebase().currentUser;
      if (user != null) {
        await GAuthService.firebase().reload();
        if (!user.isEmailVerified) {
          await GAuthService.firebase().sendEmailVerification();
        }
      }
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

  void signUpWithFacebook() async {
    try {
      await FAuthService.firebase().signUp();
      final user = FAuthService.firebase().currentUser;
      if (user != null) {
        await FAuthService.firebase().reload();
        if (!user.isEmailVerified) {
          await FAuthService.firebase().sendEmailVerification();
        }
      }
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
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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
                const Icon(
                  Icons.lock,
                  size: 50,
                ),

                const SizedBox(height: 15),

                Text(
                  'Welcome New User !',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                //text_field email
                MyTextField(
                  maxLines: 1,
                  onChanged: (value) {
                    if (!emailPattern.hasMatch(value) && value.isNotEmpty) {
                      setState(() {
                        errorTextEmail = 'Invalid Email';
                        errorBorderEmail = OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.redAccent.shade200.withOpacity(0.8),
                          ),
                        );
                        errorFocusedBorderEmail = OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red.shade900,
                          ),
                        );
                        errorTextStyleEmail = TextStyle(
                          color: Colors.red.shade900,
                        );
                      });
                    } else {
                      setState(() {
                        errorTextEmail = '';
                      });
                    }
                  },
                  errorText: (errorTextEmail.isEmpty ? null : errorTextEmail),
                  errorStyle: errorTextStyleEmail,
                  errorBorder: errorBorderEmail,
                  focusedErrorBorder: errorFocusedBorderEmail,
                  controller: _email,
                  autoCorrect: false,
                  enableSuggestions: false,
                  obscureText: false,
                  hintText: 'E-mail',
                  keyboardType: TextInputType.emailAddress,
                  horizontalPadding: 25.0,
                  verticalPadding: 0.0,
                ),

                const SizedBox(
                  height: 10,
                ),

                //text_field password
                MyTextField(
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
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        errorText = '';
                      });
                    } else if (!passPattern.hasMatch(value)) {
                      setState(() {
                        errorText = 'Weak Password';
                        errorBorder = OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.redAccent.shade200.withOpacity(0.8),
                          ),
                        );
                        errorFocusedBorder = OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red.shade900,
                          ),
                        );
                        errorTextStyle = TextStyle(
                          color: Colors.red.shade900,
                        );
                      });
                    } else {
                      setState(() {
                        errorText = 'Strong Password';
                        errorBorder = OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green.shade500,
                          ),
                        );
                        errorFocusedBorder = OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green.shade900,
                          ),
                        );
                        errorTextStyle = TextStyle(
                          color: Colors.green.shade900,
                        );
                      });
                    }
                  },
                  errorText: (errorText.isEmpty ? null : errorText),
                  errorStyle: errorTextStyle,
                  errorBorder: errorBorder,
                  focusedErrorBorder: errorFocusedBorder,
                  controller: _password,
                  autoCorrect: false,
                  enableSuggestions: false,
                  obscureText: obscureText,
                  hintText: 'Password',
                  horizontalPadding: 25.0,
                  verticalPadding: 0.0,
                ),

                const SizedBox(
                  height: 10,
                ),

                //text_field confirm password
                MyTextField(
                  maxLines: 1,
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        obscureConfirmText = !obscureConfirmText;
                      });
                    },
                    child: Icon(
                      (obscureConfirmText
                          ? Icons.visibility
                          : Icons.visibility_off),
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  onChanged: (value) {
                    if (_password.text != value && value.isNotEmpty) {
                      setState(
                        () {
                          errorTextC = 'Passwords doesn\'t match';
                          errorBorderC = OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.redAccent.shade200.withOpacity(0.8),
                            ),
                          );
                          errorFocusedBorderC = OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red.shade900,
                            ),
                          );
                          errorTextStyleC = TextStyle(
                            color: Colors.red.shade900,
                          );
                        },
                      );
                    } else {
                      setState(() {
                        errorTextC = '';
                      });
                    }
                  },
                  errorText: (errorTextC.isEmpty ? null : errorTextC),
                  errorBorder: errorBorderC,
                  focusedErrorBorder: errorFocusedBorderC,
                  errorStyle: errorTextStyleC,
                  controller: _confirmPassword,
                  autoCorrect: false,
                  enableSuggestions: false,
                  obscureText: obscureConfirmText,
                  hintText: 'Confirm Password',
                  horizontalPadding: 25.0,
                  verticalPadding: 0.0,
                ),

                const SizedBox(
                  height: 30,
                ),

                //text_button for register
                MyButton(
                  onTap: signUpWithEmailAndPassword,
                  buttonText: "Sign Up",
                ),
                const SizedBox(
                  height: 35,
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
                              color: Theme.of(context).colorScheme.tertiary),
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
                      onTap: signUpWithGoogle,
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    SquareTile(
                      path: 'lib/images/facebook_icon.png',
                      onTap: signUpWithFacebook,
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
                      'Already a user ?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
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
