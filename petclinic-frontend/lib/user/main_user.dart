import 'package:flutter/material.dart';
import 'user_page.dart';
import '../theme/app_theme.dart';

void main() {
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petclinic - User',
      theme: appTheme(),
      home: const UserPage(),
    );
  }
}
