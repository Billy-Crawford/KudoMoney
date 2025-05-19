import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const KudoApp());
}

class KudoApp extends StatelessWidget {
  const KudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KudoMoney',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
