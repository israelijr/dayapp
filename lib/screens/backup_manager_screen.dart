import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _lastBackupCode;

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
                      'O backup inclui:\n'
                      '• Banco de dados (histórias, textos, fotos, áudios)\n'
                      '• Arquivos de vídeo\n\n'
                      'Escolha o método de backup:',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Backup na Nuvem (Firebase)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          color: Colors.blue[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Backup na Nuvem',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Salvar no Firebase Storage',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ideal para restaurar em outro dispositivo. Requer conexão com internet.',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _performCloudBackup,
                      icon: const Icon(Icons.backup),
                      label: const Text('Fazer Backup Completo'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _restoreFromCloud,
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Restaurar da Nuvem'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Backup Local (Arquivo ZIP)
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
                                'Backup em Arquivo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Salvar no OneDrive, Google Drive, etc',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cria um arquivo ZIP que você pode salvar onde quiser (OneDrive, Google Drive, etc).',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createAndShareBackup,
                      icon: const Icon(Icons.share),
                      label: const Text('Criar e Compartilhar Backup'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
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
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (_lastBackupCode != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Código de Recuperação:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      _lastBackupCode!,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 20),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: _lastBackupCode!),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Código copiado!'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '⚠️ Guarde este código! Será necessário para restaurar.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.deepOrange,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _performCloudBackup() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _lastBackupCode = null;
    });

    try {
      // Verificar autenticação
      if (!_backupService.isSignedIn) {
        setState(() => _statusMessage = 'Fazendo login...');
        await _backupService.signInAnonymously();
      }

      // Fazer backup completo
      final backupCode = await _backupService.backupComplete(
        onProgress: (message) {
          setState(() => _statusMessage = message);
        },
      );

      setState(() {
        _isLoading = false;
        _statusMessage = 'Backup completo realizado com sucesso!';
        _lastBackupCode = backupCode;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Erro ao fazer backup: $e';
      });
    }
  }

  Future<void> _restoreFromCloud() async {
    // Solicitar código de recuperação
    final codeController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar da Nuvem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o código de recuperação do backup:'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Código de Recuperação',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed != true || codeController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _lastBackupCode = null;
    });

    try {
      await _backupService.restoreComplete(
        codeController.text.trim(),
        onProgress: (message) {
          setState(() => _statusMessage = message);
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

  Future<void> _createAndShareBackup() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _lastBackupCode = null;
    });

    try {
      await _backupService.shareBackupFile(
        onProgress: (message) {
          setState(() => _statusMessage = message);
        },
      );

      setState(() {
        _isLoading = false;
        _statusMessage =
            'Arquivo de backup criado! Use o menu de compartilhamento para salvá-lo.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Erro ao criar backup: $e';
      });
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
        _statusMessage = '';
        _lastBackupCode = null;
      });

      await _backupService.restoreFromZipFile(
        filePath,
        onProgress: (message) {
          setState(() => _statusMessage = message);
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
