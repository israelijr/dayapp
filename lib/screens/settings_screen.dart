import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    setState(() {
      _isSignedIn = _backupService.isSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildThemeSection(context),
          const Divider(),
          _buildBackupSection(context),
          // Espaço para futuras configurações
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: const Icon(Icons.brightness_6),
          title: const Text('Tema'),
          subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
          trailing: Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.setThemeMode(
                value ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
          onTap: () => _showThemeDialog(context, themeProvider),
        );
      },
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolher Tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Claro'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Escuro'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Sistema'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackupSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Backup',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (!_isSignedIn)
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Fazer login no Google'),
            onTap: _signIn,
          )
        else ...[
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Fazer backup'),
            onTap: _performBackup,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restaurar backup'),
            onTap: _showRestoreDialog,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair do Google'),
            onTap: _signOut,
          ),
        ],
      ],
    );
  }

  Future<void> _signIn() async {
    try {
      await _backupService.signInAnonymously();
      _checkSignInStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login anônimo realizado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao fazer login: $e')));
    }
  }

  Future<void> _signOut() async {
    await _backupService.signOut();
    _checkSignInStatus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logout realizado')));
  }

  Future<void> _performBackup() async {
    try {
      await _backupService.backupDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup realizado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao fazer backup: $e')));
    }
  }

  Future<void> _showRestoreDialog() async {
    try {
      final backups = await _backupService.listBackups();
      if (backups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum backup encontrado')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Escolher backup para restaurar'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final backup = backups[index];
                return ListTile(
                  title: Text(backup.name),
                  subtitle: Text(_extractDateFromBackupName(backup.name)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _restoreBackup(backup);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao listar backups: $e')));
    }
  }

  Future<void> _restoreBackup(Reference backup) async {
    try {
      await _backupService.restoreDatabase(backup);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restauração realizada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao restaurar: $e')));
    }
  }

  String _extractDateFromBackupName(String name) {
    // Nome: dayapp_backup_2025-09-25T14-30-00.000.db
    final regex = RegExp(r'dayapp_backup_(.+)\.db');
    final match = regex.firstMatch(name);
    if (match != null) {
      final dateStr = match.group(1)!.replaceAll('-', ':').replaceAll('T', ' ');
      try {
        final date = DateTime.parse(dateStr);
        return date.toLocal().toString();
      } catch (e) {
        return 'Data desconhecida';
      }
    }
    return 'Data desconhecida';
  }
}
