// lib/screens/kyc_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';

class KYCScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String phone;
  final String password;
  final String country;

  const KYCScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.phone,
    required this.password,
    required this.country,
  });

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}


class _KYCScreenState extends State<KYCScreen> {
  final _numeroPieceController = TextEditingController();
  File? _photoIDFile;
  File? _selfieFile;
  bool _isSubmitting = false;
  String _errorMessage = '';

  Future<File?> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    return picked != null ? File(picked.path) : null;
  }

  Future<void> _submitKYC() async {
    final numero = _numeroPieceController.text.trim();

    if (numero.isEmpty || _photoIDFile == null || _selfieFile == null) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs et sélectionner les images.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final kycUrl = Uri.parse('https://kudamoney.onrender.com/api/users/kyc/${widget.userId}/');

      final request = http.MultipartRequest('POST', kycUrl);
      request.fields['kyc_photo_id_num'] = numero;
      request.files.add(await http.MultipartFile.fromPath('kyc_photo_id', _photoIDFile!.path));
      request.files.add(await http.MultipartFile.fromPath('kyc_selfie', _selfieFile!.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("Réponse KYC : ${response.statusCode} - $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Redirection vers la connexion
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        try {
          final err = jsonDecode(responseBody);
          setState(() {
            _errorMessage = err['message'] ?? 'Erreur inconnue';
          });
        } catch (_) {
          setState(() {
            _errorMessage = 'Erreur inattendue : $responseBody';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur réseau : ${e.toString()}";
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildImageSelector(String label, File? file, Function() onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Card(
            elevation: 2,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
              ),
              child: file != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(file, fit: BoxFit.cover),
              )
                  : const Center(
                child: Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vérification d'identité")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _numeroPieceController,
              decoration: InputDecoration(
                labelText: "Numéro de la carte d'identité",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),
            _buildImageSelector("Photo de la carte", _photoIDFile, () async {
              final file = await _pickImage(ImageSource.gallery);
              if (file != null) setState(() => _photoIDFile = file);
            }),
            _buildImageSelector("Selfie (caméra)", _selfieFile, () async {
              final file = await _pickImage(ImageSource.camera);
              if (file != null) setState(() => _selfieFile = file);
            }),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.verified_user),
                label: const Text("Soumettre la vérification"),
                onPressed: _submitKYC,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
