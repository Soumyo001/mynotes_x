import 'package:flutter/material.dart';
import 'package:mynotes_x/components/my_button.dart';
import 'package:mynotes_x/components/my_text_field.dart';
import 'package:mynotes_x/components/square_tile.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/facebook_auth/facebook_auth_service.dart';
import 'package:mynotes_x/services/google_auth/google_auth_service.dart';

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

  Future<void> showErrorDialog(String messege) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.purpleAccent,
          icon: const Icon(
            Icons.error,
            color: Colors.black,
          ),
          title: Text(
            messege,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              highlightColor: Colors.black87.withOpacity(0.5),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.black87),
              ),
            )
          ],
        );
      },
    );
  }

  void showCircularProgressIndicator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 80.0,
            vertical: 330.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  signInWithEmailAndPassword() async {
    showCircularProgressIndicator(context);
    try {
      await AuthService.firebase()
          .logIn(email: _email.text, password: _password.text);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on UserNotLoggedInException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      await showErrorDialog(e.code);
    } on GenericException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      await showErrorDialog(e.code);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      await showErrorDialog('Not from own class exceptions: ${e.toString()}');
    }
  }

  signInWithGoogle() async {
    showCircularProgressIndicator(context);
    try {
      await GAuthService.firebase().signIn();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on NoEmailChoosenException {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    } on UserNotLoggedInException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      await showErrorDialog(e.code);
    } on GenericException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      await showErrorDialog(e.code);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      await showErrorDialog('not from own class exceptions: ${e.toString()}');
    }
  }

  void signInWithFacebook() async {
    try {
      await FAuthService.firebase().logIn();
    } on GenericException catch (e) {
      await showErrorDialog(e.code);
    } catch (e) {
      await showErrorDialog('not from own class exceptions: ${e.toString()}');
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
                      Text(
                        'forgot password?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
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
