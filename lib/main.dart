import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/auth.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initializeApp();
  runApp(
    MaterialApp(
      title: 'My Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthPage(),
    ),
  );
}
