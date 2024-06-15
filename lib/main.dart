import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/auth.dart';
import 'package:mynotes_x/Pages/create_update_notes_view.dart';
import 'package:mynotes_x/Pages/home_view.dart';
import 'package:mynotes_x/Pages/login_view.dart';
import 'package:mynotes_x/Pages/show_tags.dart';
import 'package:mynotes_x/notifiers/list_notifier.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/notification_services/notification_service.dart';
import 'package:mynotes_x/themes/theme_provider.dart';
import 'package:mynotes_x/utilities/constants.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initializeApp();
  await NotificationService.getInstance().initNotification(
    isScheduled: true,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ListNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const AuthPage(),
      routes: {
        createOrUpdateNotesRoute: (context) => const CreateUpdateNewNote(),
        loginRoute: (context) => const LoginView(),
        homeRoute: (context) => const HomePage(),
        showTagsRoute: (context) => const UserTags(),
      },
    );
  }
}
