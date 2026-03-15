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
      builder: (_) {
        return Consumer<LocaleProvider>(
          builder: (ctx, lp, child) {
            final loc = AppLocalizations.of(ctx)!;
            return AlertDialog(
              title: Text(loc.language),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'system',
                    groupValue: lp.selection,
                    title: Text(loc.deviceDefault),
                    onChanged: (v) {
                      if (v == null) return;
                      lp.setSelection(
                        v,
                      ); // alteração imediata, escrita em segundo plano
                      // Mantém o diálogo aberto para que o usuário veja a aplicação imediata
                    },
                  ),
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: lp.selection,
                    title: Text(loc.english),
                    onChanged: (v) {
                      if (v == null) return;
                      lp.setSelection(v);
                    },
                  ),
                  RadioListTile<String>(
                    value: 'es',
                    groupValue: lp.selection,
                    title: Text(loc.spanish),
                    onChanged: (v) {
                      if (v == null) return;
                      lp.setSelection(v);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLocalizations.of(ctx)?.close ?? 'Fechar'),
                ),
              ],
            );
          },
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

    setState(() {
      _notificationEnabled = enabled;
      _notificationAdvance = advance;
      _engagementNotificationsEnabled = engagementEnabled;
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
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
          title: Text(AppLocalizations.of(context)!.theme),
          subtitle: Text(
            // Mostra o modo e, se houver, o esquema personalizado selecionado
            themeProvider.selectedSchemeKey == null
                ? _getThemeModeText(context, themeProvider.themeMode)
                : '${_getThemeModeText(context, themeProvider.themeMode)} • ${_formatSchemeLabel(themeProvider.selectedSchemeKey!)}',
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
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.12)),
      ),
    );
  }

  String _getThemeModeText(BuildContext context, ThemeMode mode) {
    final loc = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return loc.themeLight;
      case ThemeMode.dark:
        return loc.themeDark;
      case ThemeMode.system:
        return loc.themeSystem;
    }
  }

  Widget _buildBiometricSection(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            loc.security,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // PIN de segurança
        ListTile(
          leading: const Icon(Icons.pin),
          title: Text(AppLocalizations.of(context)!.pinUnlock),
          subtitle: Text(
            _pinEnabled
                ? AppLocalizations.of(context)!.enabled
                : AppLocalizations.of(context)!.disabled,
          ),
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
            title: Text(AppLocalizations.of(context)!.changePin),
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
            title: Text(AppLocalizations.of(context)!.backgroundLock),
            subtitle: Text(
              '${AppLocalizations.of(context)!.backgroundLock}: ${InactivityService.getBackgroundTimeoutLabel(_backgroundLockTimeout, AppLocalizations.of(context)!)}',
            ),
            onTap: _showBackgroundLockTimeoutDialog,
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(AppLocalizations.of(context)!.informYourEmail),
            subtitle: Text(
              _userEmail ?? AppLocalizations.of(context)!.noEmailRegistered,
            ),
            onTap: _showEmailDialog,
          ),
        ] else if (_biometricEnabled) ...[
          // Mostra opção de timeout mesmo quando só biometria está habilitada
          ListTile(
            leading: const Icon(Icons.lock_clock),
            title: Text(loc.backgroundLock),
            subtitle: Text(
              '${loc.backgroundLock}: ${InactivityService.getBackgroundTimeoutLabel(_backgroundLockTimeout, AppLocalizations.of(context)!)}',
            ),
            onTap: _showBackgroundLockTimeoutDialog,
          ),
        ],

        const Divider(),

        // Biometria
        if (!_biometricAvailable)
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: Text(loc.biometrics),
            subtitle: Text(loc.biometricsNotAvailable),
          )
        else
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: Text(loc.enableBiometrics),
            subtitle: Text(_biometricEnabled ? loc.enabled : loc.disabled),
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: (value) async {
                if (value) {
                  _showEnableBiometricDialog();
                } else {
                  final messenger = ScaffoldMessenger.of(context);
                  final tertiaryColor = Theme.of(context).colorScheme.tertiary;
                  await _biometricService.disableBiometric();
                  await _checkBiometricStatus();
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(loc.biometricsDisabled),
                      backgroundColor: tertiaryColor,
                    ),
                  );
                }
              },
            ),
          ),
        if (_biometricEnabled)
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(loc.information),
            subtitle: Text(loc.biometricConfiguredInfo),
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
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.enableBiometrics),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(outerContext)!.biometricLoginError),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: emailController,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    label: AppLocalizations.of(context)!.password,
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
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text;

                    final messenger = ScaffoldMessenger.of(outerContext);
                    final navigator = Navigator.of(outerContext);
                    final errorColor = Theme.of(outerContext).colorScheme.error;
                    final successMessage = AppLocalizations.of(
                      outerContext,
                    )!.biometricsEnabledSuccess;

                    if (email.isEmpty || password.isEmpty) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              outerContext,
                            )!.fillEmailAndPassword,
                          ),
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
                          content: Text(loc.invalidCredentials),
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
                          content: Text(loc.invalidCredentials),
                          backgroundColor: errorColor,
                        ),
                      );
                      return;
                    }

                    // Autentica com biometria
                    final authenticated = await _biometricService.authenticate(
                      reason: loc.confirmIdentityToEnableBiometrics,
                    );

                    if (authenticated) {
                      await _biometricService.enableBiometric(email, password);
                      await _checkBiometricStatus();
                      if (!mounted) return;
                      navigator.pop();
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(successMessage),
                            backgroundColor: AppColors.emoticonGreen,
                          ),
                        );
                      }
                    } else {
                      if (!mounted) return;
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(loc.biometricAuthFailed),
                            backgroundColor: errorColor,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(AppLocalizations.of(outerContext)!.confirm),
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
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            loc.backup,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.folder_zip),
          title: Text(loc.manageCompleteBackup),
          subtitle: Text(loc.backupWithVideosZip),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.pushNamed(context, '/backup-manager');
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            loc.automaticBackup,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.backup),
          title: Text(loc.backupOnLogout),
          subtitle: Text(
            _autoBackupEnabled ? loc.backupOnLogoutDescription : loc.disabled,
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
              title: Text(loc.lastAutoBackup),
              subtitle: Text(_formatLastBackupTime(_lastAutoBackupTime!)),
              dense: true,
            ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(loc.information),
            subtitle: Text(loc.automaticBackupInfo),
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
          title: Text(AppLocalizations.of(context)!.changePin),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.enterCurrentPin),
              const SizedBox(height: 16),
              CustomTextField(
                controller: pinController,
                label: AppLocalizations.of(context)!.currentPinLabel,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 8,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
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
                      content: Text(
                        AppLocalizations.of(outerContext)!.enterPin,
                      ),
                      backgroundColor: errorColor,
                    ),
                  );
                  return;
                }

                final pinProvider = _pinProvider;
                final successMessage = AppLocalizations.of(
                  outerContext,
                )!.pinConfiguredSuccess;
                final incorrectMessage = AppLocalizations.of(
                  outerContext,
                )!.pinIncorrect;

                final success = await pinProvider.disablePin(pin);

                if (success) {
                  await _checkPinStatus();
                  if (!mounted) return;
                  navigator.pop();
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(successMessage),
                        backgroundColor: AppColors.emoticonGreen,
                      ),
                    );
                  }
                } else {
                  if (!mounted) return;
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(incorrectMessage),
                        backgroundColor: errorColor,
                      ),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(outerContext)!.confirm),
            ),
          ],
        );
      },
    );
  }

  void _showBackgroundLockTimeoutDialog() {
    final loc = AppLocalizations.of(context)!;

    // Valor selecionado, iniciado com o timeout atual
    int selectedSeconds = _backgroundLockTimeout;

    showDialog(
      context: context,
      builder: (dialogBuilderContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              loc.backgroundLock,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.backgroundLockDialogPrompt),
                  const SizedBox(height: 16),
                  // Atalhos rápidos
                  Text(
                    loc.backgroundLockSuggestions,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
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
                              AppLocalizations.of(context)!,
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: selectedSeconds == seconds
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          onPressed: () {
                            setDialogState(() => selectedSeconds = seconds);
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
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(
                    dialogBuilderContext,
                  );
                  final message =
                      '${AppLocalizations.of(dialogBuilderContext)!.backgroundLock}: ${InactivityService.getBackgroundTimeoutLabel(selectedSeconds, AppLocalizations.of(dialogBuilderContext)!)}';
                  Navigator.of(dialogBuilderContext).pop();
                  await _inactivityService.setBackgroundLockTimeout(
                    selectedSeconds,
                  );
                  await _loadBackgroundLockTimeout();
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                },
                child: Text(AppLocalizations.of(context)!.save),
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
        title: Text(
          AppLocalizations.of(context)!.informYourEmail,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.informYourEmail),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              label: AppLocalizations.of(context)!.email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogBuilderContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(dialogBuilderContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(dialogBuilderContext)!.emailInvalid,
                    ),
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
                  content: Text(
                    AppLocalizations.of(context)!.profileUpdatedSuccess,
                  ),
                  backgroundColor: AppColors.emoticonGreen,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            loc.notifications,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(loc.entryNotifications),
          subtitle: Text(_notificationEnabled ? loc.enabled : loc.disabled),
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
            title: Text(loc.defaultAdvanceTitle),
            subtitle: Text(
              NotificationPreferencesService.getAdvanceLabel(
                _notificationAdvance,
              ),
            ),
            onTap: _showNotificationAdvanceDialog,
            dense: true,
          ),
        if (_notificationEnabled)
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(loc.information),
            subtitle: Text(loc.entryNotificationsInfo),
            dense: true,
          ),
        // const Divider(),
        // ... (comentado permanece igual)
      ],
    );
  }

  void _showNotificationAdvanceDialog() {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogBuilderContext) => AlertDialog(
        title: Text(loc.notificationAdvanceTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.notificationAdvancePrompt),
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
                          '${loc.notificationAdvanceDefault}: ${NotificationPreferencesService.getAdvanceLabel(value)}',
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
            child: Text(loc.close),
          ),
        ],
      ),
    );
  }
}
