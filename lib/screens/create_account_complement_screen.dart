import 'dart:io';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../providers/auth_provider.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/custom_text_field.dart';

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
          errorMessage = AppLocalizations.of(context)!.invalidBirthDate;
          loading = false;
        });
        return;
      }
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.userNotFound;
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
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        title: Text(
          AppLocalizations.of(context)!.almostReady,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.optionalData,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
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
                          ? Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: birthDateController,
                  label: AppLocalizations.of(context)!.birthDateFormat,
                  keyboardType: TextInputType.datetime,
                  style: const TextStyle(color: Colors.black87),
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
                      backgroundColor: AppColors.primaryVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: loading ? null : () => _saveComplement(context),
                    child: loading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.create,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
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
