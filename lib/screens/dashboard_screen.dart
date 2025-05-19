// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../utils/idle_timer.dart';
import 'login_screen.dart';   //pour la redirection
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late IdleTimer _idleTimer;

  @override
  void initState() {
    super.initState();

    _idleTimer = IdleTimer(
        timeout: const Duration(minutes: 3),
        onTimeout: _handleSessionTimeout,
    );

    _idleTimer.reset();    //demarrer le timer
  }

  void _handleSessionTimeout() {
    //Redirige vers la page de login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
    );
  }

  @override
  void dipose() {
    _idleTimer.dispose();
    super.dispose();
  }

  //chaque interaction avec l'ecran redemarre le timer
void _onUserInteraction([_]) => _idleTimer.reset();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onUserInteraction,
      onPanDown: _onUserInteraction,
      child: Scaffold(
        appBar: AppBar(title: const Text("Tableau de bord")),
        body: const Center(child: Text("Bienvenue dans le Tableau de bord")),
      ),
    );
  }
}