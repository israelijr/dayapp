import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pin_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/backup_service.dart';

class BackupManagerScreen extends StatefulWidget {
  const BackupManagerScreen({super.key});

  @override
  State<BackupManagerScreen> createState() => _BackupManagerScreenState();
}

class _BackupManagerScreenState extends State<BackupManagerScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Backup'), elevation: 0),
      body: kIsWeb
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Backup não disponível na versão web',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'O recurso de backup requer acesso ao sistema de arquivos, '
                      'disponível apenas nas versões Android, iOS e Desktop.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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
                                  const Text(
                                    'Sobre o Backup',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'O backup completo inclui:\n'
                                '• Banco de dados (histórias, textos, fotos, áudios)\n'
                                '• Arquivos de vídeo\n\n'
                                'Um arquivo ZIP será criado e você pode salvá-lo onde quiser:\n'
                                '• OneDrive\n'
                                '• Google Drive\n'
                                '• Email\n'
                                '• Qualquer outro local',
                                style: TextStyle(fontSize: 14),
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
                                    color: Colors.green[700],
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Backup Completo',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Arquivo ZIP com todos os seus dados',
                                          style: TextStyle(
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
                              const Text(
                                '📦 Criar Backup:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Gera um arquivo ZIP que você pode salvar no OneDrive, Google Drive, email ou qualquer outro local.',
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : _createAndShareBackup,
                                icon: const Icon(Icons.share),
                                label: const Text(
                                  'Criar e Compartilhar Backup',
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 12),
                              const Text(
                                '📥 Restaurar Backup:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Selecione um arquivo de backup (ZIP) anteriormente criado para restaurar todos os seus dados.',
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _restoreFromFile,
                                icon: const Icon(Icons.file_upload),
                                label: const Text('Restaurar de Arquivo'),
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
                          color:
                              (_statusMessage.contains('sucesso') ||
                                  _statusMessage.contains('criado'))
                              ? Colors.green[50]
                              : Colors.red[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  (_statusMessage.contains('sucesso') ||
                                          _statusMessage.contains('criado'))
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color:
                                      (_statusMessage.contains('sucesso') ||
                                          _statusMessage.contains('criado'))
                                      ? Colors.green
                                      : Colors.red,
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
                    color: Colors.black54,
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
                                    ? 'Processando...'
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
                                'Por favor, aguarde...',
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
    // Obter o PinProvider para evitar bloqueio durante compartilhamento
    final pinProvider = Provider.of<PinProvider>(context, listen: false);

    // Seta flag ANTES de qualquer operação para evitar bloqueio
    pinProvider.isPickingExternalMedia = true;
    debugPrint('BACKUP: Flag isPickingExternalMedia = true');

    setState(() {
      _isLoading = true;
      _statusMessage = 'Iniciando backup...';
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
          _statusMessage =
              'Arquivo de backup criado! Use o menu de compartilhamento para salvá-lo.';
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
          _statusMessage = 'Erro ao criar backup: $e';
        });
      }
    }
  }

  Future<void> _restoreFromFile() async {
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
          title: const Text('⚠️ Confirmar Restauração'),
          content: const Text(
            'Todos os dados atuais serão substituídos pelo backup.\n\n'
            'Esta ação não pode ser desfeita. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Sim, Restaurar'),
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
        _statusMessage = 'Iniciando restauração...';
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
        _statusMessage = 'Restauração concluída com sucesso!';
      });

      // Mostrar diálogo de sucesso
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('✅ Restauração Concluída'),
          content: const Text(
            'O backup foi restaurado com sucesso!\n\n'
            'Todas as suas histórias foram restauradas ao estado do backup.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Voltar para a tela principal, removendo todas as telas intermediárias
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
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
          _statusMessage = 'Erro ao restaurar: $e';
        });
      }
    }
  }
}
