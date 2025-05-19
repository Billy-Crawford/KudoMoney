import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'login_screen.dart';

class KYCScreen extends StatefulWidget {
  final String username;
  final String phone;
  final String password;
  final String country;

  const KYCScreen({
    super.key,
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
  String? _selectedPieceType;
  File? _rectoFile;
  File? _versoFile;
  File? _selfieFile;
  bool _isSubmitting = false;
  String _errorMessage = '';

  final List<String> _pieceTypes = ['CNI', 'Passeport', 'Permis de conduire'];

  Future<File?> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    return picked != null ? File(picked.path) : null;
  }

  Future<void> _submitKYC() async {
    final numero = _numeroPieceController.text.trim();

    if (_selectedPieceType == null || numero.isEmpty || _rectoFile == null || _versoFile == null || _selfieFile == null) {
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
      // Étape 1 : Enregistrement utilisateur
      final registerUrl = Uri.parse('https://kudamoney.onrender.com/api/users/register/');
      final registerResponse = await http.post(
        registerUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phone,
          'password': widget.password,
          'pays': widget.country,
          'username': widget.username,
        }),
      );

      if (registerResponse.statusCode != 200 && registerResponse.statusCode != 201) {
        final err = jsonDecode(registerResponse.body);
        throw Exception(err['message'] ?? 'Échec de l’enregistrement');
      }

      final registerJson = jsonDecode(registerResponse.body);
      final token = registerJson['token'];

      // Étape 2 : Envoi des fichiers KYC
      final kycUrl = Uri.parse('https://kudamoney.onrender.com/api/users/kyc/');
      final request = http.MultipartRequest('POST', kycUrl);
      request.fields['numero_piece'] = numero;
      request.fields['type_piece'] = _selectedPieceType!;
      request.files.add(await http.MultipartFile.fromPath('recto_file', _rectoFile!.path));
      request.files.add(await http.MultipartFile.fromPath('verso_file', _versoFile!.path));
      request.files.add(await http.MultipartFile.fromPath('selfie_file', _selfieFile!.path));

      request.headers['Authorization'] = 'Bearer $token';

      final kycResponse = await request.send();

      if (kycResponse.statusCode == 200 || kycResponse.statusCode == 201) {
        // Succès ➜ retour à la connexion
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        }
      } else {
        final resBody = await kycResponse.stream.bytesToString();
        final error = jsonDecode(resBody);
        setState(() => _errorMessage = error['message'] ?? 'Échec de la vérification KYC');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildImageSelector(String label, File? file, Function() onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: file != null
                ? Image.file(file, fit: BoxFit.cover)
                : const Center(child: Icon(Icons.camera_alt, size: 40)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vérification d'identité")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPieceType,
              items: _pieceTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => _selectedPieceType = val),
              decoration: const InputDecoration(labelText: "Type de pièce"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numeroPieceController,
              decoration: const InputDecoration(labelText: "Numéro de la pièce"),
            ),
            const SizedBox(height: 16),
            _buildImageSelector("Recto de la pièce", _rectoFile, () async {
              final file = await _pickImage(ImageSource.gallery);
              if (file != null) setState(() => _rectoFile = file);
            }),
            _buildImageSelector("Verso de la pièce", _versoFile, () async {
              final file = await _pickImage(ImageSource.gallery);
              if (file != null) setState(() => _versoFile = file);
            }),
            _buildImageSelector("Selfie", _selfieFile, () async {
              final file = await _pickImage(ImageSource.camera);
              if (file != null) setState(() => _selfieFile = file);
            }),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitKYC,
              child: const Text("Soumettre la vérification"),
            ),
          ],
        ),
      ),
    );
  }
}
