import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
      body: SingleChildScrollView(
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

            // Status/Progresso
            if (_isLoading || _statusMessage.isNotEmpty)
              Card(
                color: _isLoading
                    ? Colors.blue[50]
                    : _statusMessage.contains('sucesso')
                    ? Colors.green[50]
                    : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_isLoading) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ] else
                        Icon(
                          _statusMessage.contains('sucesso')
                              ? Icons.check_circle
                              : Icons.error,
                          color: _statusMessage.contains('sucesso')
                              ? Colors.green
                              : Colors.red,
                          size: 48,
                        ),
                      const SizedBox(height: 12),
                      Text(
                        _statusMessage.isEmpty && _isLoading
                            ? 'Processando...'
                            : _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
    try {
      // Selecionar arquivo ZIP
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.single.path == null) {
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

      if (confirmed != true) return;

      setState(() {
        _isLoading = true;
        _statusMessage = 'Iniciando restauração...';
      });

      await _backupService.restoreFromZipFile(
        filePath,
        onProgress: (message) {
          if (mounted) {
            setState(() => _statusMessage = message);
          }
        },
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _statusMessage =
            'Restauração completa! Reinicie o aplicativo para ver as mudanças.';
      });

      // Mostrar diálogo de sucesso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('✅ Restauração Concluída'),
          content: const Text(
            'O backup foi restaurado com sucesso!\n\n'
            'Por favor, reinicie o aplicativo para que as mudanças tenham efeito.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Voltar para tela anterior
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Erro ao restaurar: $e';
      });
    }
  }
}
