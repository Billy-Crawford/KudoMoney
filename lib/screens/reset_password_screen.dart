import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _message = '';

  void _resetPassword() {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _message = "Veuillez entrer votre numéro de téléphone.";
      });
      return;
    }

    // Simuler l'envoi du code de réinitialisation
    setState(() {
      _message = "Un code de réinitialisation a été envoyé à $phone.";
    });

    // TODO: Intégrer l'envoi réel via backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Réinitialiser le mot de passe"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Entrez votre numéro de téléphone pour réinitialiser le mot de passe.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Numéro de téléphone",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("Réinitialiser", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: const TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
