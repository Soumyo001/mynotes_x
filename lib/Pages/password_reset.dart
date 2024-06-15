import 'package:flutter/material.dart';
import 'package:mynotes_x/utilities/dialogs/info_dialog.dart';

class PasswordResetView extends StatefulWidget {
  const PasswordResetView({super.key});

  @override
  State<PasswordResetView> createState() => _PasswordResetViewState();
}

class _PasswordResetViewState extends State<PasswordResetView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        title: const Text(
          'Email Sent !',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A link has been sent to your email to reset your password. \n Please check your email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Didn\'t recieved the link?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await showInfoDialog(
                        context, 'Link Sent', 'Email has been resend');
                  },
                  child: const Text(
                    'Resend',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
