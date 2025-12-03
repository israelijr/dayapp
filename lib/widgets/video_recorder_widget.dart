import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/pin_provider.dart';

/// Widget de seleção de vídeo que oferece opção de gravar ou buscar arquivos.
/// Suporta seleção múltipla de vídeos da galeria/arquivos.
class VideoRecorderWidget extends StatefulWidget {
  /// Callback para quando um único vídeo é selecionado (compatibilidade)
  final Function(Uint8List video, int duration)? onVideoRecorded;

  /// Callback para quando múltiplos vídeos são selecionados
  /// Cada item contém: {video: Uint8List, duration: int}
  final Function(List<Map<String, dynamic>> videos)? onMultipleVideosSelected;

  /// Se true, permite seleção múltipla de arquivos
  final bool allowMultiple;

  const VideoRecorderWidget({
    this.onVideoRecorded,
    this.onMultipleVideosSelected,
    super.key,
    this.allowMultiple = true,
  }) : assert(
         onVideoRecorded != null || onMultipleVideosSelected != null,
         'Deve fornecer onVideoRecorded ou onMultipleVideosSelected',
       );

  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

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
            Text(
              widget.allowMultiple ? 'Adicionar Vídeos' : 'Adicionar Vídeo',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )
            else ...[
              Text(
                widget.allowMultiple
                    ? 'Escolha uma opção (arquivos permite múltiplos vídeos):'
                    : 'Escolha uma opção:',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.allowMultiple
                    ? _pickMultipleVideoFiles
                    : _pickVideoFile,
                icon: const Icon(Icons.folder_open),
                label: Text(
                  widget.allowMultiple
                      ? 'Selecionar arquivos de vídeo'
                      : 'Buscar arquivo de vídeo',
                ),
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
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Seleciona múltiplos arquivos de vídeo
  Future<void> _pickMultipleVideoFiles() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      // Se o usuário cancelou, reseta a flag e retorna
      if (result == null || result.files.isEmpty) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      if (!mounted) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }
      setState(() => _isLoading = true);

      final List<Map<String, dynamic>> videoDataList = [];
      for (final platformFile in result.files) {
        if (platformFile.path != null) {
          final file = File(platformFile.path!);
          final bytes = await file.readAsBytes();
          // Duração estimada (placeholder)
          const estimatedDuration = 0;
          videoDataList.add({'video': bytes, 'duration': estimatedDuration});
        }
      }

      // Usa callback de múltiplos vídeos se disponível
      if (widget.onMultipleVideosSelected != null) {
        widget.onMultipleVideosSelected!(videoDataList);
      } else if (widget.onVideoRecorded != null) {
        for (final videoData in videoDataList) {
          widget.onVideoRecorded!(
            videoData['video'] as Uint8List,
            videoData['duration'] as int,
          );
        }
      }

      // Reseta a flag após processar os vídeos
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      Navigator.of(context).pop();

      // Mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            videoDataList.length == 1
                ? 'Vídeo adicionado com sucesso!'
                : '${videoDataList.length} vídeos adicionados com sucesso!',
          ),
        ),
      );
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar vídeos: $e')));
    }
  }

  /// Seleciona um único arquivo de vídeo (modo único)
  Future<void> _pickVideoFile() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      // Se o usuário cancelou, reseta a flag e retorna
      if (result == null || result.files.single.path == null) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();

      // Estima duração (placeholder)
      const estimatedDuration = 0;

      if (widget.onVideoRecorded != null) {
        widget.onVideoRecorded!(bytes, estimatedDuration);
      } else if (widget.onMultipleVideosSelected != null) {
        widget.onMultipleVideosSelected!([
          {'video': bytes, 'duration': estimatedDuration},
        ]);
      }

      // Reseta a flag após processar o vídeo
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar arquivo: $e')));
    }
  }

  /// Grava um vídeo usando a câmera
  Future<void> _recordVideo() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10), // Limite de 10 minutos
      );

      // Se o usuário cancelou, reseta a flag e retorna
      if (video == null) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      final file = File(video.path);
      final bytes = await file.readAsBytes();

      // Duração estimada
      const estimatedDuration = 0;

      if (widget.onVideoRecorded != null) {
        widget.onVideoRecorded!(bytes, estimatedDuration);
      } else if (widget.onMultipleVideosSelected != null) {
        widget.onMultipleVideosSelected!([
          {'video': bytes, 'duration': estimatedDuration},
        ]);
      }

      // Reseta a flag após processar o vídeo
      pinProvider.isPickingExternalMedia = false;

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
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gravar vídeo: $e')));
    }
  }
}
