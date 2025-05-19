// lib/utils/idle_timer.dart

import 'dart:async';
import 'package:flutter/material.dart';

class IdleTimer {
  final Duration timeout;
  final VoidCallback onTimeout;
  Timer? _timer;
  bool _isActive = false;

  IdleTimer({required this.timeout, required this.onTimeout});

  /// commence ou redemarre le timer
void reset() {
  _timer?.cancel();
  _timer = Timer(timeout, _handleTimeout);
  _isActive = true;
}

/// Arrete et supprime le timer
void dispose() {
  _timer?.cancel();
  _isActive = false;
}

///Interne : appel de la fonction quand le delai est depasse
void _handleTimeout() {
  _isActive = false;
  onTimeout();
}

/// Verifie si le timer tourne encore
bool get isRunning => _isActive;
}
