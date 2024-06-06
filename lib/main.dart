import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mynotes_x/Pages/auth.dart';
import 'package:mynotes_x/Pages/create_update_notes_view.dart';
import 'package:mynotes_x/Pages/home_view.dart';
import 'package:mynotes_x/Pages/login_view.dart';
import 'package:mynotes_x/Pages/show_tags.dart';
import 'package:mynotes_x/notifiers/list_notifier.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/notification_services/notification_service.dart';
import 'package:mynotes_x/themes/theme.dart';
import 'package:mynotes_x/utilities/constants.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initializeApp();
  await NotificationService.getInstance().initNotification(
    isScheduled: true,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ListNotifier(),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Notes',
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: ThemeMode.system,
        home: const MyApp(),
        routes: {
          createOrUpdateNotesRoute: (context) => const CreateUpdateNewNote(),
          loginRoute: (context) => const LoginView(),
          homeRoute: (context) => const HomePage(),
          showTagsRoute: (context) => const UserTags(),
        },
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void onClickedNotification(String? payload) async {
    if (AuthService.firebase().currentUser == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        loginRoute,
        (route) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return HomePage(
            payload: payload,
          );
        }),
      );
    }
  }

  void listenToNotifications() {
    NotificationService.getInstance()
        .onClick
        .stream
        .listen(onClickedNotification);
  }

  @override
  void initState() {
    listenToNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const AuthPage();
  }
}
