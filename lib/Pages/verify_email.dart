import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/utilities/show_error_dialog.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                  child: Lottie.network(
                    'https://lottie.host/9fbf770c-8358-4228-a1ce-f6df62af9c86/oZwnNXZ2fN.json',
                  ),
                ),
                Text(
                  'Email has been sent!',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Please check your inbox and follow the \n instructions to verify your email.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      await AuthService.firebase().reload();
                    } on UserNotLoggedInException catch (e) {
                      await showErrorDialog(
                        context: context,
                        messege: e.code,
                      );
                    } catch (e) {
                      await showErrorDialog(
                        context: context,
                        messege:
                            'Not from own class Exception: ${e.toString()}',
                      );
                    }
                    if (!AuthService.firebase().currentUser!.isEmailVerified) {
                      await showErrorDialog(
                        context: context,
                        messege: 'Please confirm your email',
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 70,
                    ),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Center(
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Didn\'t receive the link?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      await AuthService.firebase().sendEmailverification();
                    } on UserNotLoggedInException catch (e) {
                      await showErrorDialog(
                        context: context,
                        messege: e.code,
                      );
                    } catch (e) {
                      await showErrorDialog(
                        context: context,
                        messege:
                            'Not from own class exceptions: ${e.toString()}',
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.flip(
                        flipX: true,
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        'Resend',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
