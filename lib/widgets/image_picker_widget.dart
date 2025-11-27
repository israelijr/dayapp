import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget de seleção de imagem que oferece opção de tirar foto ou buscar na galeria.
/// Segue o mesmo padrão de UX do AudioRecorderWidget e VideoRecorderWidget.
class ImagePickerWidget extends StatefulWidget {
  final Function(Uint8List image) onImagePicked;
  final double? maxWidth;
  final double? maxHeight;
  final int? imageQuality;

  const ImagePickerWidget({
    required this.onImagePicked, super.key,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              'Adicionar Foto',
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
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Buscar na galeria'),
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
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tirar uma foto'),
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

  /// Seleciona uma imagem da galeria
  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();

        widget.onImagePicked(bytes);

        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
    }
  }

  /// Tira uma foto usando a câmera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      if (photo != null) {
        final file = File(photo.path);
        final bytes = await file.readAsBytes();

        widget.onImagePicked(bytes);

        if (!mounted) return;
        Navigator.of(context).pop();

        // Mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto capturada com sucesso!')),
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
      ).showSnackBar(SnackBar(content: Text('Erro ao tirar foto: $e')));
    }
  }
}
