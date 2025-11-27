import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VideoRecorderWidget extends StatefulWidget {
  final Function(Uint8List video, int duration) onVideoRecorded;

  const VideoRecorderWidget({required this.onVideoRecorded, super.key});

  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              'Adicionar Vídeo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Escolha uma opção:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickVideoFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Buscar arquivo de vídeo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _recordVideo,
              icon: const Icon(Icons.videocam),
              label: const Text('Gravar um vídeo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();

        // Estima duração (placeholder - pode ser melhorado com um plugin de metadata)
        const estimatedDuration = 0; // Em segundos

        widget.onVideoRecorded(bytes, estimatedDuration);

        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar arquivo: $e')));
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10), // Limite de 10 minutos
      );

      if (video != null) {
        final file = File(video.path);
        final bytes = await file.readAsBytes();

        // Duração pode ser estimada ou obtida através de metadata
        const estimatedDuration = 0; // Em segundos

        if (!mounted) return;

        widget.onVideoRecorded(bytes, estimatedDuration);

        if (!mounted) return;
        Navigator.of(context).pop();

        // Mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vídeo gravado com sucesso!')),
        );

        // Limpa o arquivo temporário se necessário
        try {
          await file.delete();
        } catch (_) {
          // Ignora erro ao deletar arquivo temporário
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gravar vídeo: $e')));
    }
  }
}
