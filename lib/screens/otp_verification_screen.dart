// lib/screens/otp_verification_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phone;

  const OTPVerificationScreen({super.key, required this.phone});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  late TextEditingController _phoneController;
  bool _isLoading = false;
  bool _isResending = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phone);
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final url = Uri.parse('https://kudamoney.onrender.com/api/users/verify-otp/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': _phoneController.text.trim(),
        'otp': _otpController.text.trim(),
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);

      // 🔁 Appeler l’API pour récupérer le nom d’utilisateur et le solde
      final walletResponse = await http.get(
        Uri.parse('https://kudamoney.onrender.com/api/wallets/wallet/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (walletResponse.statusCode == 200) {
        final walletData = jsonDecode(walletResponse.body);

        final userName = walletData['user_name'] ?? 'Utilisateur';
        final balance = walletData['balance'] ?? 0;

        await prefs.setString('user_name', userName.toString());
        await prefs.setString('balance', balance.toString());

        // ✅ Naviguer vers le Dashboard avec les bonnes données
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              username: userName.toString(),
              balance: balance.toString(),
            ),
          ),
              (route) => false,
        );
      } else {
        setState(() => _errorMessage = "Impossible de récupérer le portefeuille.");
      }
    } else {
      final errorJson = jsonDecode(response.body);
      setState(() => _errorMessage = errorJson['message'] ?? "Code incorrect. Veuillez réessayer.");
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final url = Uri.parse('https://kudamoney.onrender.com/api/users/resend-otp/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': _phoneController.text.trim()}),
    );

    setState(() => _isResending = false);

    if (response.statusCode == 200) {
      setState(() => _successMessage = "Nouveau code OTP envoyé avec succès.");
    } else {
      final errorJson = jsonDecode(response.body);
      setState(() => _errorMessage = errorJson['message'] ?? "Échec de l’envoi du code OTP.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Vérification OTP"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sms, size: 60, color: Colors.blueAccent),
                  const SizedBox(height: 20),
                  Text(
                    "Un code OTP a été envoyé à ce numéro :",
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Numéro de téléphone",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Code OTP",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                  if (_successMessage.isNotEmpty)
                    Text(_successMessage, style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Vérifier",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: _isResending ? null : _resendOtp,
                    icon: _isResending
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.refresh),
                    label: const Text("Renvoyer le code"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
