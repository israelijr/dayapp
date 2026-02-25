// ignore_for_file: deprecated_member_use
// TODO: Migrar RadioListTile para RadioGroup quando Flutter 3.32+ for estável
// Os RadioListTile usam groupValue/onChanged que foram deprecados no Flutter 3.32+
// A migração requer refatoração significativa dos dialogs para StatefulWidgets

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../providers/locale_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auto_backup_service.dart';
import '../services/battery_optimization_service.dart';
import '../services/biometric_service.dart';
import '../services/engagement_service.dart';
import '../services/inactivity_service.dart';
import '../services/notification_preferences_service.dart';
import '../services/pin_recovery_service.dart';
import '../services/secure_storage_service.dart';
import '../theme/custom_color_schemes.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/custom_text_field.dart';
import 'setup_pin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  final InactivityService _inactivityService = InactivityService();
  final PinRecoveryService _recoveryService = PinRecoveryService();
  final NotificationPreferencesService _notificationService =
      NotificationPreferencesService();
  final AutoBackupService _autoBackupService = AutoBackupService();
  final EngagementService _engagementService = EngagementService();
  final BatteryOptimizationService _batteryService =
      BatteryOptimizationService();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  int _backgroundLockTimeout =
      InactivityService.defaultBackgroundTimeoutSeconds;
  bool _notificationEnabled = true;
  int _notificationAdvance =
      NotificationPreferencesService.defaultAdvanceMinutes;
  // ignore: unused_field
  bool _engagementNotificationsEnabled = true;
  // ignore: unused_field
  bool? _batteryOptimizationDisabled;
  String? _userEmail;
  late PinProvider _pinProvider;

  // Estado do backup automático
  bool _autoBackupEnabled = false;
  DateTime? _lastAutoBackupTime;

  @override
  void initState() {
    super.initState();
    _pinProvider = Provider.of<PinProvider>(context, listen: false);
    _checkBiometricStatus();
    _checkPinStatus();
    _loadBackgroundLockTimeout();
    _loadNotificationPreferences();
    _loadUserEmail();
    _loadAutoBackupSettings();
  }

  Widget _buildLanguageSection(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    final loc = AppLocalizations.of(context)!;
    late final String subtitle;
    switch (localeProvider.selection) {
      case 'en':
        subtitle = loc.english;
        break;
      case 'es':
        subtitle = loc.spanish;
        break;
      case 'system':
      default:
        subtitle = loc.deviceDefault;
    }

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(loc.language),
      subtitle: Text(subtitle),
      onTap: () => _showLanguageDialog(context, localeProvider),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LocaleProvider localeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final loc = AppLocalizations.of(context)!;
        final current = localeProvider.selection;
        return AlertDialog(
          title: Text(loc.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'system',
                groupValue: current,
                title: Text(loc.deviceDefault),
                onChanged: (v) {
                  if (v == null) return;
                  // Persiste a escolha assincronamente e fecha o diálogo
                  localeProvider.setSelection(v);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                value: 'en',
                groupValue: current,
                title: Text(loc.english),
                onChanged: (v) {
                  if (v == null) return;
                  localeProvider.setSelection(v);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                value: 'es',
                groupValue: current,
                title: Text(loc.spanish),
                onChanged: (v) {
                  if (v == null) return;
                  localeProvider.setSelection(v);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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

  Future<void> _loadBackgroundLockTimeout() async {
    final timeout = await _inactivityService.getBackgroundLockTimeout();
    setState(() {
      _backgroundLockTimeout = timeout;
    });
  }

  Future<void> _loadUserEmail() async {
    final email = await _recoveryService.getUserEmail();
    setState(() {
      _userEmail = email;
    });
  }

  Future<void> _loadNotificationPreferences() async {
    final enabled = await _notificationService.isNotificationEnabled();
    final advance = await _notificationService.getDefaultNotificationAdvance();
    final engagementEnabled = await _engagementService.isEnabled();
    final batteryDisabled = await _batteryService
        .isBatteryOptimizationDisabled();
    setState(() {
      _notificationEnabled = enabled;
      _notificationAdvance = advance;
      _engagementNotificationsEnabled = engagementEnabled;
      _batteryOptimizationDisabled = batteryDisabled;
    });
  }

  Future<void> _loadAutoBackupSettings() async {
    final enabled = await _autoBackupService.isEnabled();
    final lastBackup = await _autoBackupService.getLastBackupTime();
    setState(() {
      _autoBackupEnabled = enabled;
      _lastAutoBackupTime = lastBackup;
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
          _buildLanguageSection(context),
          const Divider(),
          _buildBiometricSection(context),
          const Divider(),
          _buildNotificationSection(context),
          const Divider(),
          _buildBackupSection(context),
          const Divider(),
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
          subtitle: Text(
            // Mostra o modo e, se houver, o esquema personalizado selecionado
            themeProvider.selectedSchemeKey == null
                ? _getThemeModeText(themeProvider.themeMode)
                : '${_getThemeModeText(themeProvider.themeMode)} • ${_formatSchemeLabel(themeProvider.selectedSchemeKey!)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview do esquema atual (pequeno gradiente com primary/secondary)
              _buildSchemePreview(context, themeProvider),
              const SizedBox(width: 8),
              Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ],
          ),
          onTap: () => _showThemeDialog(context, themeProvider),
        );
      },
    );
  }

  // Retorna um rótulo legível para a chave do esquema
  String _formatSchemeLabel(String key) {
    switch (key) {
      case 'relvaLight':
        return 'Relva (Claro)';
      case 'relvaDark':
        return 'Relva (Escuro)';
      case 'outonoLight':
        return 'Outono (Claro)';
      case 'outonoDark':
        return 'Outono (Escuro)';
      default:
        return key;
    }
  }

  // Widget que desenha uma pré-visualização pequena do esquema ativo
  Widget _buildSchemePreview(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final schemeKey = themeProvider.selectedSchemeKey;
    final ColorScheme scheme =
        (schemeKey != null &&
            CustomColorSchemes.customSchemes.containsKey(schemeKey))
        ? CustomColorSchemes.customSchemes[schemeKey]!
        : Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(colors: [scheme.primary, scheme.secondary]),
        border: Border.all(color: scheme.onSurface.withOpacity(0.12)),
      ),
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
            // contentPadding: const EdgeInsets.only(left: 57.0),
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

        if (_pinEnabled) ...[
          ListTile(
            leading: const Icon(Icons.lock_clock),
            title: const Text('Bloqueio em Segundo Plano'),
            subtitle: Text(
              'Bloquear após: ${InactivityService.getBackgroundTimeoutLabel(_backgroundLockTimeout)}',
            ),
            onTap: _showBackgroundLockTimeoutDialog,
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('E-mail para Recuperação'),
            subtitle: Text(_userEmail ?? 'Não configurado'),
            onTap: _showEmailDialog,
          ),
        ] else if (_biometricEnabled) ...[
          // Mostra opção de timeout mesmo quando só biometria está habilitada
          ListTile(
            leading: const Icon(Icons.lock_clock),
            title: const Text('Bloqueio em Segundo Plano'),
            subtitle: Text(
              'Bloquear após: ${InactivityService.getBackgroundTimeoutLabel(_backgroundLockTimeout)}',
            ),
            onTap: _showBackgroundLockTimeoutDialog,
          ),
        ],

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
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Informações'),
            subtitle: Text(
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
                  CustomTextField(
                    controller: emailController,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Senha',
                    obscureText: obscurePassword,
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

                    final messenger = ScaffoldMessenger.of(outerContext);
                    final navigator = Navigator.of(outerContext);
                    final errorColor = Theme.of(outerContext).colorScheme.error;

                    if (email.isEmpty || password.isEmpty) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: const Text('Preencha todos os campos'),
                          backgroundColor: Theme.of(
                            outerContext,
                          ).colorScheme.error,
                        ),
                      );
                      return;
                    }

                    // Verifica as credenciais usando hash
                    final db = await DatabaseHelper().database;
                    final result = await db.query(
                      'users',
                      where: 'email = ?',
                      whereArgs: [email],
                    );

                    if (result.isEmpty) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: const Text('E-mail ou senha inválidos'),
                          backgroundColor: errorColor,
                        ),
                      );
                      return;
                    }

                    // Verifica a senha com o hash armazenado
                    final storedPassword = result.first['senha'] as String;
                    final secureStorage = SecureStorageService();
                    if (!secureStorage.verifyPassword(
                      password,
                      storedPassword,
                    )) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: const Text('E-mail ou senha inválidos'),
                          backgroundColor: errorColor,
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
                      navigator.pop();
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Biometria habilitada com sucesso!',
                            ),
                            backgroundColor: AppColors.emoticonGreen,
                          ),
                        );
                      }
                    } else {
                      if (!mounted) return;
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Falha na autenticação biométrica',
                            ),
                            backgroundColor: errorColor,
                          ),
                        );
                      }
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
          title: const Text('Tema e Esquema'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setThemeMode(ThemeMode.light);
                themeProvider.setSelectedSchemeKey(null);
                Navigator.of(context).pop();
              },
              child: ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text('Claro'),
                subtitle: const Text('Tema claro padrão'),
                trailing:
                    themeProvider.themeMode == ThemeMode.light &&
                        themeProvider.selectedSchemeKey == null
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                themeProvider.setSelectedSchemeKey(null);
                Navigator.of(context).pop();
              },
              child: ListTile(
                leading: const Icon(Icons.nights_stay),
                title: const Text('Escuro'),
                subtitle: const Text('Tema escuro padrão'),
                trailing:
                    themeProvider.themeMode == ThemeMode.dark &&
                        themeProvider.selectedSchemeKey == null
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setThemeMode(ThemeMode.system);
                themeProvider.setSelectedSchemeKey(null);
                Navigator.of(context).pop();
              },
              child: ListTile(
                leading: const Icon(Icons.phone_iphone),
                title: const Text('Sistema'),
                subtitle: const Text('Seguir tema do sistema'),
                trailing:
                    themeProvider.themeMode == ThemeMode.system &&
                        themeProvider.selectedSchemeKey == null
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Esquemas Personalizados',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setSelectedSchemeKey('relvaLight');
                Navigator.of(context).pop();
              },
              child: ListTile(
                leading: const Icon(Icons.eco),
                title: const Text('Relva (Claro)'),
                subtitle: const Text('Tons verdes e naturais'),
                trailing: themeProvider.selectedSchemeKey == 'relvaLight'
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setSelectedSchemeKey('relvaDark');
                Navigator.of(context).pop();
              },
              child: ListTile(
                leading: const Icon(Icons.eco),
                title: const Text('Relva (Escuro)'),
                subtitle: const Text('Versão escura do esquema Relva'),
                trailing: themeProvider.selectedSchemeKey == 'relvaDark'
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setSelectedSchemeKey('outonoLight');
                Navigator.of(context).pop();
              },
              child: ListTile(
                leading: const Icon(Icons.park),
                title: const Text('Outono (Claro)'),
                subtitle: const Text('Tons quentes e terrosos'),
                trailing: themeProvider.selectedSchemeKey == 'outonoLight'
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setSelectedSchemeKey('outonoDark');
                Navigator.of(context).pop();
              },
              child: ListTile(
                leading: const Icon(Icons.park),
                title: const Text('Outono (Escuro)'),
                subtitle: const Text('Versão escura do esquema Outono'),
                trailing: themeProvider.selectedSchemeKey == 'outonoDark'
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setSelectedSchemeKey(null);
                Navigator.of(context).pop();
              },
              child: ListTile(
                leading: const Icon(Icons.clear),
                title: const Text('Remover Esquema'),
                subtitle: const Text('Voltar ao esquema padrão do tema'),
                trailing: themeProvider.selectedSchemeKey == null
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
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
        const Divider(indent: 16, endIndent: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Backup Automático',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.backup),
          title: const Text('Backup ao Sair'),
          subtitle: Text(
            _autoBackupEnabled
                ? 'Backup será criado ao fazer logout'
                : 'Desabilitado',
          ),
          value: _autoBackupEnabled,
          onChanged: (value) async {
            await _autoBackupService.setEnabled(value);
            await _loadAutoBackupSettings();
          },
        ),
        if (_autoBackupEnabled) ...[
          if (_lastAutoBackupTime != null)
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Último Backup Automático'),
              subtitle: Text(_formatLastBackupTime(_lastAutoBackupTime!)),
              dense: true,
            ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Informação'),
            subtitle: Text(
              'Ao fazer logout, um backup será criado e você poderá '
              'escolher onde salvar (pasta local, Google Drive, etc).',
            ),
            dense: true,
          ),
        ],
      ],
    );
  }

  /// Formata a data do último backup para exibição
  String _formatLastBackupTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    final formatted = '$day/$month/$year às $hour:$minute';

    if (difference.inMinutes < 1) {
      return '$formatted (agora)';
    } else if (difference.inMinutes < 60) {
      return '$formatted (${difference.inMinutes} min atrás)';
    } else if (difference.inHours < 24) {
      return '$formatted (${difference.inHours}h atrás)';
    } else {
      return '$formatted (${difference.inDays} dia(s) atrás)';
    }
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
              CustomTextField(
                controller: pinController,
                label: 'PIN atual',
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

                final messenger = ScaffoldMessenger.of(outerContext);
                final navigator = Navigator.of(outerContext);
                final errorColor = Theme.of(outerContext).colorScheme.error;

                if (pin.isEmpty) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Digite o PIN'),
                      backgroundColor: errorColor,
                    ),
                  );
                  return;
                }

                final pinProvider = _pinProvider;
                final success = await pinProvider.disablePin(pin);

                if (success) {
                  await _checkPinStatus();
                  if (!mounted) return;
                  navigator.pop();
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('PIN desabilitado com sucesso!'),
                        backgroundColor: AppColors.emoticonGreen,
                      ),
                    );
                  }
                } else {
                  if (!mounted) return;
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('PIN incorreto'),
                        backgroundColor: errorColor,
                      ),
                    );
                  }
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showBackgroundLockTimeoutDialog() {
    // Determina a unidade e o valor com base no timeout atual
    String selectedUnit = 'min';
    int displayValue = 0;

    if (_backgroundLockTimeout == 0) {
      displayValue = 0;
      selectedUnit = 'min';
    } else if (_backgroundLockTimeout >= 3600 &&
        _backgroundLockTimeout % 3600 == 0) {
      displayValue = _backgroundLockTimeout ~/ 3600;
      selectedUnit = 'h';
    } else if (_backgroundLockTimeout >= 60 &&
        _backgroundLockTimeout % 60 == 0) {
      displayValue = _backgroundLockTimeout ~/ 60;
      selectedUnit = 'min';
    } else {
      displayValue = _backgroundLockTimeout;
      selectedUnit = 'seg';
    }

    final controller = TextEditingController(
      text: displayValue == 0 ? '' : displayValue.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogBuilderContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Converte o valor digitado para segundos
          int calculateSeconds() {
            final text = controller.text.trim();
            if (text.isEmpty) return 0;
            final value = int.tryParse(text) ?? 0;
            if (value <= 0) return 0;
            switch (selectedUnit) {
              case 'seg':
                return value;
              case 'min':
                return value * 60;
              case 'h':
                return value * 3600;
              default:
                return value * 60;
            }
          }

          final currentSeconds = calculateSeconds();

          return AlertDialog(
            title: const Text(
              'Bloqueio em Segundo Plano',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Após quanto tempo em segundo plano o app deve ser bloqueado?',
                  ),
                  const SizedBox(height: 12),

                  // Campo de entrada com seletor de unidade
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: controller,
                          label: 'Tempo',
                          hintText: '0 = imediato',
                          keyboardType: TextInputType.number,
                          // não mostrar suffixText para evitar renderização vertical indesejada
                          // Força single-line com padding reduzido para evitar altura excessiva
                          minLines: 1,
                          maxLines: 1,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          onChanged: (_) => setDialogState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Seletor de unidade
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'seg', label: Text('seg')),
                          ButtonSegment(value: 'min', label: Text('min')),
                          ButtonSegment(value: 'h', label: Text('h')),
                        ],
                        selected: {selectedUnit},
                        onSelectionChanged: (value) {
                          setDialogState(() {
                            selectedUnit = value.first;
                          });
                        },
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  // Mostra o valor resultante
                  Text(
                    'Resultado: ${InactivityService.getBackgroundTimeoutLabel(currentSeconds)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Atalhos rápidos
                  const Text(
                    'Sugestões:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final seconds
                          in InactivityService.backgroundTimeoutOptions)
                        ActionChip(
                          label: Text(
                            InactivityService.getBackgroundTimeoutLabel(
                              seconds,
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: currentSeconds == seconds
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          onPressed: () {
                            // Determina unidade e valor para o atalho
                            if (seconds == 0) {
                              controller.text = '';
                              setDialogState(() => selectedUnit = 'min');
                            } else if (seconds >= 3600 && seconds % 3600 == 0) {
                              controller.text = (seconds ~/ 3600).toString();
                              setDialogState(() => selectedUnit = 'h');
                            } else if (seconds >= 60 && seconds % 60 == 0) {
                              controller.text = (seconds ~/ 60).toString();
                              setDialogState(() => selectedUnit = 'min');
                            } else {
                              controller.text = seconds.toString();
                              setDialogState(() => selectedUnit = 'seg');
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogBuilderContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.of(dialogBuilderContext).pop();
                  await _inactivityService.setBackgroundLockTimeout(
                    currentSeconds,
                  );
                  await _loadBackgroundLockTimeout();
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Bloqueio em segundo plano: ${InactivityService.getBackgroundTimeoutLabel(currentSeconds)}',
                      ),
                    ),
                  );
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEmailDialog() {
    final emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (dialogBuilderContext) => AlertDialog(
        title: const Text(
          'E-mail para Recuperação',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Configure um e-mail para recuperar seu PIN caso esqueça.',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              label: 'E-mail',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogBuilderContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(dialogBuilderContext).showSnackBar(
                  SnackBar(
                    content: const Text('E-mail inválido'),
                    backgroundColor: Theme.of(
                      dialogBuilderContext,
                    ).colorScheme.error,
                  ),
                );
                return;
              }

              Navigator.of(dialogBuilderContext).pop(); // Fecha antes do await
              await _recoveryService.saveUserEmail(email);
              await _loadUserEmail();

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('E-mail salvo com sucesso!'),
                  backgroundColor: AppColors.emoticonGreen,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Notificações',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notificações de Entradas'),
          subtitle: Text(_notificationEnabled ? 'Habilitado' : 'Desabilitado'),
          trailing: Switch(
            value: _notificationEnabled,
            onChanged: (value) async {
              await _notificationService.setNotificationEnabled(value);
              await _loadNotificationPreferences();
            },
          ),
        ),
        if (_notificationEnabled)
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Antecedência Padrão'),
            subtitle: Text(
              NotificationPreferencesService.getAdvanceLabel(
                _notificationAdvance,
              ),
            ),
            onTap: _showNotificationAdvanceDialog,
            dense: true,
          ),
        if (_notificationEnabled)
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Informação'),
            subtitle: Text(
              'Entradas com data pelo menos 2 horas à frente podem ter notificações agendadas.',
            ),
            dense: true,
          ),
        // const Divider(),
        // ListTile(
        //   leading: const Icon(Icons.auto_awesome),
        //   title: const Text('Lembretes de Reflexão'),
        //   subtitle: Text(
        //     _engagementNotificationsEnabled
        //         ? 'Reserve um momento para você'
        //         : 'Desabilitado',
        //   ),
        //   trailing: Switch(
        //     value: _engagementNotificationsEnabled,
        //     onChanged: (value) async {
        //       await _engagementService.setEnabled(value);
        //       await _loadNotificationPreferences();
        //     },
        //   ),
        // ),
        // if (_engagementNotificationsEnabled)
        //   const ListTile(
        //     leading: Icon(Icons.info_outline),
        //     title: Text('Sobre lembretes'),
        //     subtitle: Text(
        //       'Você receberá um lembrete carinhoso para registrar suas memórias e reflexões se ficar alguns dias sem abrir o app.',
        //     ),
        //     dense: true,
        //   ),
        // if (_engagementNotificationsEnabled &&
        //     _batteryOptimizationDisabled == false)
        //   ListTile(
        //     leading: const Icon(Icons.battery_alert, color: Colors.orange),
        //     title: const Text('Otimização de Bateria'),
        //     subtitle: const Text(
        //       'Lembretes podem não funcionar. Toque para configurar.',
        //     ),
        //     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        //     onTap: () async {
        //       await _batteryService.requestDisableBatteryOptimization();
        //       await _loadNotificationPreferences();
        //     },
        //   ),
        // if (_engagementNotificationsEnabled &&
        //     _batteryOptimizationDisabled == true)
        //   const ListTile(
        //     leading: Icon(Icons.check_circle, color: Colors.green),
        //     title: Text('Otimização de Bateria'),
        //     subtitle: Text('Configurado corretamente'),
        //     dense: true,
        //   ),
      ],
    );
  }

  void _showNotificationAdvanceDialog() {
    showDialog(
      context: context,
      builder: (dialogBuilderContext) => AlertDialog(
        title: const Text('Antecedência da Notificação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Com quanto tempo de antecedência você quer ser notificado?',
            ),
            const SizedBox(height: 16),
            ...NotificationPreferencesService.advanceOptions.map((minutes) {
              return RadioListTile<int>(
                title: Text(
                  NotificationPreferencesService.getAdvanceLabel(minutes),
                ),
                value: minutes,
                groupValue: _notificationAdvance,
                onChanged: (value) async {
                  if (value != null) {
                    Navigator.of(context).pop(); // Fecha antes do await
                    await _notificationService.setDefaultNotificationAdvance(
                      value,
                    );
                    await _loadNotificationPreferences();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Antecedência padrão: ${NotificationPreferencesService.getAdvanceLabel(value)}',
                        ),
                      ),
                    );
                  }
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogBuilderContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
