import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/components/my_button.dart';
import 'package:mynotes/components/my_text_field.dart';
import 'package:mynotes/firebase_options.dart';

class LoginView extends StatefulWidget {
  final void Function()? onTap;
  const LoginView({super.key, required this.onTap});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  void showMessege(String messege) {
    showDialog(
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
            style: const TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }

  void signInWithEmailAndPassword() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Loaging...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      showMessege(e.code);
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
      backgroundColor: Colors.grey[300],
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return SafeArea(
                // SafeArea(child : Center(child : Column(children)))
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Icon
                        const Icon(
                          Icons.lock,
                          size: 85,
                        ),

                        const SizedBox(height: 15),

                        Text(
                          'User Login',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 50),

                        //text_field email
                        MyTextField(
                          controller: _email,
                          autoCorrect: false,
                          enableSuggestions: false,
                          obscureText: false,
                          hintText: 'E-mail',
                          type: TextInputType.emailAddress,
                          horizontalPadding: 25.0,
                          verticalPadding: 0.0,
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        //text_field password
                        MyTextField(
                          controller: _password,
                          autoCorrect: false,
                          enableSuggestions: false,
                          obscureText: true,
                          hintText: 'Password',
                          horizontalPadding: 25.0,
                          verticalPadding: 0.0,
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
                                  color: Colors.grey.shade600,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'not a member?',
                              style: TextStyle(color: Colors.grey[700]),
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
              );
            default:
              return const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
