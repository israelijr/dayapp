import 'package:file_picker/file_picker.dart';
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
      body: Stack(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                          onPressed: _isLoading ? null : _createAndShareBackup,
                          icon: const Icon(Icons.share),
                          label: const Text('Criar e Compartilhar Backup'),
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
            Container(
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
                          child: CircularProgressIndicator(strokeWidth: 5),
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

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage =
              'Arquivo de backup criado! Use o menu de compartilhamento para salvá-lo.';
        });
      }
    } catch (e) {
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

    // Salvar o estado atual do shouldShowPinScreen para restaurar depois se necessário
    final previousShouldShowPinScreen = pinProvider.shouldShowPinScreen;

    try {
      // Marcar que estamos selecionando mídia externa E forçar shouldShowPinScreen = false
      // Isso previne que o PinProtectedWrapper mostre a tela de bloqueio
      pinProvider.isPickingExternalMedia = true;
      pinProvider.shouldShowPinScreen = false;

      // Selecionar arquivo ZIP
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      // Manter shouldShowPinScreen = false durante toda a operação
      // Não desmarcar isPickingExternalMedia ainda, pois o main.dart fará isso

      if (result == null || result.files.single.path == null) {
        // Usuário cancelou a seleção - restaurar estado do PIN
        pinProvider.isPickingExternalMedia = false;
        pinProvider.shouldShowPinScreen = previousShouldShowPinScreen;
        return;
      }

      final filePath = result.files.single.path!;

      if (!mounted) return;

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
        // Usuário cancelou a confirmação - restaurar estado do PIN
        pinProvider.isPickingExternalMedia = false;
        pinProvider.shouldShowPinScreen = previousShouldShowPinScreen;
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

      if (!mounted) return;

      // Notificar provider para atualizar todas as telas
      Provider.of<RefreshProvider>(context, listen: false).refresh();

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
      // Garantir que as flags sejam restauradas em caso de erro
      pinProvider.isPickingExternalMedia = false;
      pinProvider.shouldShowPinScreen = previousShouldShowPinScreen;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Erro ao restaurar: $e';
        });
      }
    }
  }
}
