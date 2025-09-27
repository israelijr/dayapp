import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/refresh_provider.dart';
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
            leading: const Icon(Icons.restore_from_trash),
            title: const Text('Restaurar com código'),
            onTap: _showRestoreWithCodeDialog,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login anônimo realizado com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao fazer login: $e')));
    }
  }

  Future<void> _signOut() async {
    await _backupService.signOut();
    _checkSignInStatus();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logout realizado')));
  }

  Future<void> _performBackup() async {
    try {
      final backupCode = await _backupService.backupDatabase();
      if (!mounted) return;
      _showBackupCodeDialog(backupCode);
      // Try to open the user's email client with the backup code
      _emailBackupCode(backupCode);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao fazer backup: $e')));
    }
  }

  Future<void> _emailBackupCode(String backupCode) async {
    try {
      // Get the current user email from AuthProvider
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final String? email = auth.user?.email;
      final subject = 'Backup DayApp';
      final body = 'Seu código de backup é: $backupCode';

      // Prefer the system share sheet (share_plus) so the user can choose any app
      try {
        final params = ShareParams(text: body, subject: subject);
        await SharePlus.instance.share(params);
        return;
      } catch (_) {
        // If share sheet not available, fall back to email intent if email exists
      }

      if (email == null || email.isEmpty) {
        // No configured email — copy and notify
        await Clipboard.setData(ClipboardData(text: backupCode));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código copiado para a área de transferência.'),
          ),
        );
        return;
      }

      final subjectEnc = Uri.encodeComponent(subject);
      final bodyEnc = Uri.encodeComponent(body);
      final uri = Uri.parse('mailto:$email?subject=$subjectEnc&body=$bodyEnc');

      if (!await canLaunchUrl(uri)) {
        await Clipboard.setData(ClipboardData(text: backupCode));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o cliente de e-mail. Código copiado para a área de transferência.',
            ),
          ),
        );
        return;
      }

      final launched = await launchUrl(uri);
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: backupCode));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o cliente de e-mail. Código copiado para a área de transferência.',
            ),
          ),
        );
      }
    } catch (e) {
      // On any unexpected failure, copy the code so the user can still send it manually
      await Clipboard.setData(ClipboardData(text: backupCode));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Falha ao tentar enviar e-mail: $e. Código copiado para a área de transferência.',
          ),
        ),
      );
    }
  }

  void _showBackupCodeDialog(String backupCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup realizado com sucesso!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Anote o código de recuperação abaixo. Você precisará dele para restaurar o backup em caso de reinstalação do app.',
            ),
            const SizedBox(height: 16),
            Text(
              backupCode,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Este código também foi enviado para o seu email (se configurado).',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Try to open email client when user taps explicitly
              Navigator.of(context).pop();
              _emailBackupCode(backupCode);
            },
            child: const Text('Enviar por e-mail'),
          ),
          TextButton(
            onPressed: () {
              // Copy to clipboard as a fallback
              Clipboard.setData(ClipboardData(text: backupCode));
              Navigator.of(context).pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Código copiado para a área de transferência'),
                ),
              );
            },
            child: const Text('Copiar código'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestoreDialog([String? backupCode]) async {
    try {
      final backups = await _backupService.listBackups(backupCode);
      if (backups.isEmpty) {
        if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao listar backups: $e')));
    }
  }

  Future<void> _showRestoreWithCodeDialog() async {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar backup com código'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Código de recuperação',
            hintText: 'Digite o código anotado durante o backup',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isEmpty) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Digite o código de recuperação'),
                  ),
                );
                return;
              }
              Navigator.of(context).pop();
              await _showRestoreDialog(code);
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(Reference backup) async {
    try {
      await _backupService.restoreDatabase(backup);
      // Refresh home screen data
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();
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
