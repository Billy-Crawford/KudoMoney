import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'kyc_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedCountry;
  String _countryCode = '';
  bool _isLoading = false;
  String _errorMessage = '';

  final Map<String, String> _countryCodes = {
    'TCHAD': '+235',
    'TOGO': '+228',
  };

  Future<void> _submitRegistration() async {
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || phone.isEmpty || password.isEmpty || _selectedCountry == null) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs.';
      });
      return;
    }

    final fullPhone = '$_countryCode$phone';

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://kudamoney.onrender.com/api/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'phone': fullPhone,
          'password': password,
          'pays': _selectedCountry,
        }),
      );

      Map<String, dynamic> data = {};

      try {
        if (response.headers['content-type']?.contains('application/json') ?? false) {
          data = jsonDecode(response.body);
        } else {
          throw Exception('Réponse inattendue du serveur. Code: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Erreur lors de la lecture de la réponse: ${e.toString()}';
        });
        return;
      }

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final userId = data['user_id']; // ← corriger ici (user_id au lieu de id)
        if (userId == null) {
          throw Exception('Identifiant utilisateur introuvable dans la réponse.');
        }

        // Aller à l'écran KYC avec les données
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KYCScreen(
              username: username,
              phone: fullPhone,
              password: password,
              country: _selectedCountry!,
              userId: userId,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Une erreur est survenue.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/kudo1-rbg.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Inscription",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Username
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Nom d'utilisateur",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Country dropdown
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: _countryCodes.keys.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  _countryCode = _countryCodes[value]!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Pays",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Phone with country code
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: Text(
                    _countryCode.isEmpty ? "+___" : _countryCode,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Numéro de téléphone",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Error message
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),

            // Submit button
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitRegistration,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("Soumettre", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),

            // Go to login
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("Déjà inscrit ? Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}
