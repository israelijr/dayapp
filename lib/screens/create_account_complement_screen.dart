import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

class CreateAccountComplementScreen extends StatefulWidget {
  const CreateAccountComplementScreen({super.key});

  @override
  State<CreateAccountComplementScreen> createState() =>
      _CreateAccountComplementScreenState();
}

class _CreateAccountComplementScreenState
    extends State<CreateAccountComplementScreen> {
  final birthDateController = TextEditingController();
  String? profileImagePath;
  String? errorMessage;
  bool loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        profileImagePath = picked.path;
      });
    }
  }

  Future<void> _saveComplement(BuildContext context) async {
    final navigator = Navigator.of(context);
    setState(() {
      loading = true;
      errorMessage = null;
    });
    DateTime? birthDate;
    if (birthDateController.text.isNotEmpty) {
      try {
        birthDate = DateFormat('dd/MM/yyyy').parse(birthDateController.text);
      } catch (_) {
        setState(() {
          errorMessage = 'Data de nascimento inválida (use DD/MM/AAAA)';
          loading = false;
        });
        return;
      }
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) {
      setState(() {
        errorMessage = 'Usuário não encontrado.';
        loading = false;
      });
      return;
    }
    final db = await DatabaseHelper().database;
    await db.update(
      'users',
      {
        'dt_nascimento': birthDate != null
            ? DateFormat('dd/MM/yyyy').format(birthDate)
            : null,
        'foto_perfil': profileImagePath,
      },
      where: 'id = ?',
      whereArgs: [auth.user!.id],
    );
    if (!mounted) return;
    setState(() {
      loading = false;
    });
    navigator.popUntil(ModalRoute.withName('/login'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB388FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'quase pronto...',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Os dados abaixo são opcionais',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImagePath != null
                          ? FileImage(File(profileImagePath!))
                          : null,
                      child: profileImagePath == null
                          ? const Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Color(0xFFB388FF),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Theme(
                  data: Theme.of(context).copyWith(brightness: Brightness.dark),
                  child: TextField(
                    controller: birthDateController,
                    keyboardType: TextInputType.datetime,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Data de nascimento (DD/MM/AAAA)',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: loading ? null : () => _saveComplement(context),
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Criar',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
