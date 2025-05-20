//lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:kudo_m/screens/register_screen.dart';
import 'package:kudo_m/screens/reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    print('Numéro: ${_phoneController.text}, Mot de passe: ${_passwordController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Logo
              Center(
                child: Image.asset(
                  'assets/kudo1-rbg.png', // ⚠️ vérifie que ce fichier existe dans assets
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                "Connexion",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // 📱 Téléphone
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Numéro de téléphone",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 20),

              // 🔒 Mot de passe
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              // 🔽 ESPACE AVANT LE BOUTON
              const SizedBox(height: 50),

              // 🔘 Bouton Se connecter
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 70),

              // 🔗 Lien de bas de page
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text("Pas encore inscrit ?, Créer un compte"),
              ),
              // 🔁 Lien Mot de passe oublié
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
