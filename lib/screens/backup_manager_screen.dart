import 'dart:io';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/auto_backup_service.dart';
import '../services/backup_service.dart';
import '../theme/m3_expressive_theme.dart';

class BackupManagerScreen extends StatefulWidget {
  const BackupManagerScreen({super.key});

  @override
  State<BackupManagerScreen> createState() => _BackupManagerScreenState();
}

class _BackupManagerScreenState extends State<BackupManagerScreen> {
  final BackupService _backupService = BackupService();
  final AutoBackupService _autoBackupService = AutoBackupService();
  bool _isLoading = false;
  String _statusMessage = '';
  double? _progressValue;
  bool _statusIsError = false; // nova flag para colorir card de status
  bool _statusIsSuccess = false;
  List<File> _localBackups =
      []; // lista de backups automáticos salvos localmente

  @override
  void initState() {
    super.initState();
    _loadLocalBackups();
  }

  /// Carrega a lista de backups automáticos salvos localmente
  Future<void> _loadLocalBackups() async {
    try {
      final backups = await _autoBackupService.listLocalBackups();
      if (!mounted) return;
      setState(() {
        _localBackups = backups;
      });
    } catch (e) {
      // Silencia erro — lista de backups não crítica para o funcionamento da tela
      debugPrint('Erro ao carregar backups locais: $e');
    }
  }

  /// Restaura um backup automático selecionado
  Future<void> _restoreLocalBackup(File backupFile) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.restoreConfirmTitle),
        content: Text(
          '${loc.restoreConfirmContent}\n\n${backupFile.path.split('/').last}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.restore),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _progressValue = null;
      _statusIsError = false;
      _statusIsSuccess = false;
    });

    try {
      await _backupService.restoreFromZipFile(
        backupFile.path,
        onProgress: (msg) {
          if (mounted) {
            setState(() {
              _statusMessage = msg;
            });
          }
        },
        onProgressValue: (value) {
          if (mounted) {
            setState(() {
              _progressValue = value;
            });
          }
        },
        l10n: loc,
      );

      if (mounted) {
        setState(() {
          _statusMessage = loc.restoreSuccessContent;
          _statusIsError = false;
          _statusIsSuccess = true;
        });
        // Faz logout após restauração bem-sucedida
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final pinProvider = Provider.of<PinProvider>(context, listen: false);
        await auth.logout();
        pinProvider.updateUserLoginStatus(false);
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = loc.restoreError(e.toString());
          _statusIsError = true;
          _statusIsSuccess = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Compartilha um backup automático
  Future<void> _shareLocalBackup(File backupFile) async {
    final loc = AppLocalizations.of(context)!;
    try {
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: loc.autoBackupShareSubject,
        text: backupFile.path.split('/').last,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.backupShareError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Deleta um backup automático
  Future<void> _deleteLocalBackup(File backupFile) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.delete),
        content: Text(loc.backupDeleteConfirm(backupFile.path.split('/').last)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(loc.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await backupFile.delete();
      await _loadLocalBackups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.deleted),
            backgroundColor: AppColors.emoticonGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.backupDeleteError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.manageBackups)),
      body: kIsWeb
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.backupNotAvailableWeb,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.backupNotAvailableDetail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                // Conteúdo principal
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Informação sobre backup
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.backupInfoTitle,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                loc.backupInfoDetails,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Backup em Arquivo ZIP
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.folder_zip,
                                    color: AppColors.emoticonGreen,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loc.backupComplete,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          loc.backupZipSubtitle,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '📦 ${loc.backupComplete}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loc.backupZipExplanation,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : _createAndShareBackup,
                                icon: const Icon(Icons.share),
                                label: Text(loc.createAndShareBackup),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 12),
                              Text(
                                '📥 ${loc.restoreSectionTitle}:',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loc.restoreSectionDescription,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.tonalIcon(
                                onPressed: _isLoading ? null : _restoreFromFile,
                                icon: const Icon(Icons.file_upload),
                                label: Text(loc.restoreFromFile),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Seção de backups automáticos salvos localmente
                      Builder(
                        builder: (context) {
                          final premium = context.watch<PremiumProvider>();
                          if (!premium.canUseAutomaticBackup) {
                            // Banner para usuários Free
                            return Card(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLow,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.workspace_premium,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '✨ ${loc.premiumPlan}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            loc.autoBackupPremiumRequired,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          // Lista de backups (Premium)
                          if (_localBackups.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.backup,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '💾 ${loc.autoBackupsSavedTitle}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            loc.autoBackupsSavedCount(
                                              _localBackups.length,
                                            ),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ..._localBackups.map(
                                        (backup) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Card(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainerLow,
                                            child: ListTile(
                                              dense: true,
                                              leading: const Icon(
                                                Icons.archive,
                                                size: 20,
                                              ),
                                              title: Text(
                                                _formatBackupDate(
                                                  backup.path.split('/').last,
                                                  context,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              subtitle: FutureBuilder(
                                                future: backup.length(),
                                                builder: (context, snapshot) {
                                                  final bytes =
                                                      snapshot.data ?? 0;
                                                  return Text(
                                                    _formatFileSize(bytes),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  );
                                                },
                                              ),
                                              trailing: PopupMenuButton(
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    child: ListTile(
                                                      dense: true,
                                                      leading: const Icon(
                                                        Icons.restore,
                                                        size: 18,
                                                      ),
                                                      title: Text(
                                                        loc.restore,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        _restoreLocalBackup(
                                                          backup,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    child: ListTile(
                                                      dense: true,
                                                      leading: const Icon(
                                                        Icons.share,
                                                        size: 18,
                                                      ),
                                                      title: Text(
                                                        loc.share,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        _shareLocalBackup(
                                                          backup,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    child: ListTile(
                                                      dense: true,
                                                      leading: const Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.red,
                                                      ),
                                                      title: Text(
                                                        loc.delete,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        _deleteLocalBackup(
                                                          backup,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),

                      // Mensagem de status (quando não está carregando)
                      if (!_isLoading && _statusMessage.isNotEmpty)
                        Card(
                          color: _statusIsError
                              ? Theme.of(context).colorScheme.errorContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  _statusIsSuccess
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: _statusIsError
                                      ? Theme.of(context).colorScheme.error
                                      : AppColors.emoticonGreen,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _statusMessage,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Overlay de carregamento - cobre toda a tela
                if (_isLoading)
                  ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.all(32),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  strokeWidth: 5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _statusMessage.isEmpty
                                    ? loc.processing
                                    : _statusMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 200,
                                child: LinearProgressIndicator(
                                  value: _progressValue,
                                ),
                              ),
                              if (_progressValue != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '${(_progressValue! * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Text(
                                loc.pleaseWait,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _createAndShareBackup() async {
    final loc = AppLocalizations.of(context)!;
    // Obter o PinProvider para evitar bloqueio durante compartilhamento
    final pinProvider = Provider.of<PinProvider>(context, listen: false);

    // Seta flag ANTES de qualquer operação para evitar bloqueio
    pinProvider.isPickingExternalMedia = true;
    debugPrint('BACKUP: Flag isPickingExternalMedia = true');

    setState(() {
      _isLoading = true;
      _statusMessage = loc.backupStarting;
      _progressValue = null;
      _statusIsError = false;
      _statusIsSuccess = false;
    });

    try {
      await _backupService.shareBackupFile(
        onProgress: (message) {
          if (mounted) {
            setState(() => _statusMessage = message);
          }
        },
        onProgressValue: (value) {
          if (mounted) {
            setState(() => _progressValue = value);
          }
        },
        l10n: loc,
      );

      debugPrint('BACKUP: Compartilhamento concluído');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = loc.backupCreatedSuccess;
          _progressValue = null;
          _statusIsError = false;
          _statusIsSuccess = true;
        });
      }

      // Aguarda um tempo para garantir que todos os eventos de lifecycle foram processados
      // antes de resetar a flag (o share sheet pode disparar múltiplos eventos resumed)
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('BACKUP: Resetando flag após delay');
      pinProvider.isPickingExternalMedia = false;
    } catch (e) {
      debugPrint('BACKUP: Erro, resetando flag: $e');
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = loc.backupError(e.toString());
          _progressValue = null;
          _statusIsError = true;
          _statusIsSuccess = false;
        });
      }
    }
  }

  Future<void> _restoreFromFile() async {
    final loc = AppLocalizations.of(context)!;
    // Obter o PinProvider para evitar bloqueio durante seleção de arquivo
    final pinProvider = Provider.of<PinProvider>(context, listen: false);

    // Seta flag ANTES de qualquer operação para evitar bloqueio
    pinProvider.isPickingExternalMedia = true;
    debugPrint('RESTORE: Flag isPickingExternalMedia = true');

    try {
      // Selecionar arquivo ZIP
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.single.path == null) {
        // Usuário cancelou a seleção - aguarda antes de resetar
        debugPrint('RESTORE: Usuário cancelou, aguardando antes de resetar');
        await Future.delayed(const Duration(milliseconds: 500));
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      final filePath = result.files.single.path!;

      if (!mounted) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      // Confirmar restauração
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(loc.restoreConfirmTitle),
          content: Text(loc.restoreConfirmContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
              child: Text(loc.confirm),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        // Usuário cancelou a confirmação
        debugPrint('RESTORE: Usuário cancelou confirmação, resetando flag');
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      setState(() {
        _isLoading = true;
        _statusMessage = loc.restoreStarting;
        _progressValue = null;
        _statusIsError = false;
        _statusIsSuccess = false;
      });

      // Aguardar o próximo frame para garantir que o setState foi processado
      await Future.delayed(const Duration(milliseconds: 100));

      await _backupService.restoreFromZipFile(
        filePath,
        onProgress: (message) {
          if (mounted) {
            setState(() => _statusMessage = message);
          }
        },
        onProgressValue: (value) {
          if (mounted) {
            setState(() => _progressValue = value);
          }
        },
        l10n: loc,
      );

      if (!mounted) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      // Notificar provider para atualizar todas as telas
      Provider.of<RefreshProvider>(context, listen: false).refresh();

      debugPrint('RESTORE: Restauração concluída, resetando flag');
      // Reseta a flag após processamento completo
      pinProvider.isPickingExternalMedia = false;

      setState(() {
        _isLoading = false;
        _statusMessage = loc.restoreSuccess;
        _progressValue = null;
        _statusIsError = false;
        _statusIsSuccess = true;
      });

      // Mostrar diálogo de sucesso
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(loc.restoreSuccessTitle),
          content: Text(loc.restoreSuccessContent),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                Navigator.pop(dialogContext);
                // Faz logout e redireciona para o login
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.logout();
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: Text(loc.accessAccount),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('RESTORE: Erro, resetando flag: $e');
      // Garantir que a flag seja resetada em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = loc.restoreError(e.toString());
          _progressValue = null;
          _statusIsError = true;
          _statusIsSuccess = false;
        });
      }
    }
  }

  /// Extrai e formata a data/hora do nome do arquivo de backup de forma amigável
  String _formatBackupDate(String filename, BuildContext context) {
    // Nome esperado: backup_2026-03-22T15-30-00.zip
    try {
      final withoutExt = filename.replaceAll('.zip', '');
      final parts = withoutExt.split('_');
      if (parts.length < 2) return filename;
      // Normaliza T e hífens de hora -> `:` para parse
      final raw = parts.sublist(1).join('_');
      final iso = raw.replaceFirstMapped(
        RegExp(r'T(\d{2})-(\d{2})-(\d{2})'),
        (m) => 'T${m[1]}:${m[2]}:${m[3]}',
      );
      final date = DateTime.tryParse(iso);
      if (date == null) return filename;
      final locale = Localizations.localeOf(context).toLanguageTag();
      final dateStr = DateFormat.yMd(locale).format(date);
      final timeStr = DateFormat.Hm(locale).format(date);
      return '$dateStr  $timeStr';
    } catch (_) {
      return filename;
    }
  }

  /// Formata um tamanho de arquivo em bytes para string legível
  String _formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size > 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }
}
