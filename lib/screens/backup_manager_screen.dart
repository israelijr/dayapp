import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/backup_service.dart';
import '../theme/m3_expressive_theme.dart';

class BackupManagerScreen extends StatefulWidget {
  const BackupManagerScreen({super.key});

  @override
  State<BackupManagerScreen> createState() => _BackupManagerScreenState();
}

class _BackupManagerScreenState extends State<BackupManagerScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  String _statusMessage = '';
  bool _statusIsError = false; // nova flag para colorir card de status

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.manageBackups), elevation: 0),
      body: kIsWeb
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
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
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                                    color: Theme.of(context).primaryColor,
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
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
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
                              ElevatedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : _createAndShareBackup,
                                icon: const Icon(Icons.share),
                                label: Text(loc.createAndShareBackup),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  backgroundColor: AppColors.emoticonGreen,
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
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _restoreFromFile,
                                icon: const Icon(Icons.file_upload),
                                label: Text(loc.restoreFromFile),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  backgroundColor: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

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
                                  (_statusMessage.contains('sucesso') ||
                                          _statusMessage.contains('criado'))
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
                              const SizedBox(
                                width: 200,
                                child: LinearProgressIndicator(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                loc.pleaseWait,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
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
      _statusIsError = false;
    });

    try {
      await _backupService.shareBackupFile(
        onProgress: (message) {
          if (mounted) {
            setState(() => _statusMessage = message);
          }
        },
      );

      debugPrint('BACKUP: Compartilhamento concluído');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = loc.backupCreatedSuccess;
          _statusIsError = false;
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
          _statusIsError = true;
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
        _statusIsError = false;
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
        _statusIsError = false;
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
          _statusIsError = true;
        });
      }
    }
  }
}
