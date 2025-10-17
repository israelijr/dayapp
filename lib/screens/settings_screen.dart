import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/pin_provider.dart';
import '../services/biometric_service.dart';
import '../db/database_helper.dart';
import 'manage_groups_screen.dart';
import 'setup_pin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  late PinProvider _pinProvider;

  @override
  void initState() {
    super.initState();
    _pinProvider = Provider.of<PinProvider>(context, listen: false);
    _checkBiometricStatus();
    _checkPinStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricEnabled();

    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = enabled;
    });
  }

  Future<void> _checkPinStatus() async {
    final enabled = await _pinProvider.checkPinEnabled();

    setState(() {
      _pinEnabled = enabled;
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
          _buildBiometricSection(context),
          const Divider(),
          _buildBackupSection(context),
          const Divider(),
          _buildGroupsSection(context),
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

  Widget _buildBiometricSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Segurança',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // PIN de segurança
        ListTile(
          leading: const Icon(Icons.pin),
          title: const Text('PIN de Desbloqueio'),
          subtitle: Text(_pinEnabled ? 'Habilitado' : 'Desabilitado'),
          trailing: Switch(
            value: _pinEnabled,
            onChanged: (value) async {
              if (value) {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SetupPinScreen(),
                  ),
                );
                if (result == true) {
                  await _checkPinStatus();
                }
              } else {
                _showDisablePinDialog();
              }
            },
          ),
        ),

        if (_pinEnabled)
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Alterar PIN'),
            dense: true,
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const SetupPinScreen(isChanging: true),
                ),
              );
              if (result == true) {
                await _checkPinStatus();
              }
            },
          ),

        if (_pinEnabled)
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Informações'),
            subtitle: Text(
              'O PIN será solicitado sempre que você abrir o aplicativo '
              'ou voltar de outro aplicativo.',
            ),
            dense: true,
          ),

        const Divider(),

        // Biometria
        if (!_biometricAvailable)
          const ListTile(
            leading: Icon(Icons.fingerprint),
            title: Text('Biometria'),
            subtitle: Text('Não disponível neste dispositivo'),
          )
        else
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Login com Biometria'),
            subtitle: Text(_biometricEnabled ? 'Habilitado' : 'Desabilitado'),
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: (value) async {
                if (value) {
                  _showEnableBiometricDialog();
                } else {
                  await _biometricService.disableBiometric();
                  await _checkBiometricStatus();
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Biometria desabilitada'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ),
        if (_biometricEnabled)
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Informações'),
            subtitle: const Text(
              'A biometria está configurada. '
              'Você pode fazer login usando sua digital ou reconhecimento facial.',
            ),
            dense: true,
          ),
      ],
    );
  }

  void _showEnableBiometricDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    final outerContext = context;

    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Habilitar Biometria'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Para habilitar a biometria, confirme suas credenciais:',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: obscurePassword,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text;

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(outerContext).showSnackBar(
                        const SnackBar(
                          content: Text('Preencha todos os campos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Verifica as credenciais
                    final db = await DatabaseHelper().database;
                    final result = await db.query(
                      'users',
                      where: 'email = ? AND senha = ?',
                      whereArgs: [email, password],
                    );

                    if (result.isEmpty) {
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(outerContext).showSnackBar(
                        const SnackBar(
                          content: Text('E-mail ou senha inválidos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Autentica com biometria
                    final authenticated = await _biometricService.authenticate(
                      reason:
                          'Confirme sua identidade para habilitar a biometria',
                    );

                    if (authenticated) {
                      await _biometricService.enableBiometric(email, password);
                      await _checkBiometricStatus();
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(outerContext).showSnackBar(
                        const SnackBar(
                          content: Text('Biometria habilitada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(outerContext).showSnackBar(
                        const SnackBar(
                          content: Text('Falha na autenticação biométrica'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Escolher Tema'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.of(context).pop();
              },
              child: const Text('Claro'),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.of(context).pop();
              },
              child: const Text('Escuro'),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.of(context).pop();
              },
              child: const Text('Sistema'),
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
        ListTile(
          leading: const Icon(Icons.folder_zip),
          title: const Text('Gerenciar Backup Completo'),
          subtitle: const Text('Backup com vídeos em arquivo ZIP'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.pushNamed(context, '/backup-manager');
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showDisablePinDialog() {
    final pinController = TextEditingController();
    final outerContext = context;

    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Desabilitar PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Para desabilitar o PIN, digite seu PIN atual:'),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN atual',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 8,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinController.text.trim();

                if (pin.isEmpty) {
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    const SnackBar(
                      content: Text('Digite o PIN'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final pinProvider = _pinProvider;
                final success = await pinProvider.disablePin(pin);

                if (success) {
                  await _checkPinStatus();
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    const SnackBar(
                      content: Text('PIN desabilitado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    const SnackBar(
                      content: Text('PIN incorreto'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupsSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.group),
      title: const Text('Gerenciar Grupos'),
      subtitle: const Text('Editar e excluir grupos'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ManageGroupsScreen()),
        );
      },
    );
  }
}
