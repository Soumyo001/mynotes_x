import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final Widget child;
  const MyDrawer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shadowColor: Theme.of(context).colorScheme.shadow,
      backgroundColor: Theme.of(context).colorScheme.background,
      child: child,
    );
  }
}
