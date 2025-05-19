// lib/screens/home_screen.dart


import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../utils/idle_timer.dart';
import 'login_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late IdleTimer _idleTimer;

  @override
  void initState() {
    super.initState();
    _idleTimer = IdleTimer(
      timeout: const Duration(minutes: 3),
      onTimeout: _logout,
    );
    _idleTimer.reset();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _idleTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _idleTimer.reset(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Dashboard")),
        body: const Center(child: Text("Bienvenue 👋")),
      ),
    );
  }
}

