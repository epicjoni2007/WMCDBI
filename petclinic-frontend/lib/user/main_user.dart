import 'package:flutter/material.dart';
import 'user_page.dart';

void main() {
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF116E57);
    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);
    return MaterialApp(
      title: 'Petclinic - User',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      home: const UserPage(),
    );
  }
}
