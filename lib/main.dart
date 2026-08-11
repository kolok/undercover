import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(const UndercoverApp());
}

class UndercoverApp extends StatelessWidget {
  const UndercoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Undercover',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
