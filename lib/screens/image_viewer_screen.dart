import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';

import '../db/historia_foto_helper.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<Uint8List> images;
  final List<int>? photoIds; // optional DB ids corresponding to images
  final int? historiaId; // optional for context
  final int initialIndex;
  const ImageViewerScreen({
    super.key,
    required this.images,
    this.photoIds,
    this.historiaId,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shareCurrent() async {
    try {
      final bytes = widget.images[_currentIndex];
      await Share.shareXFiles([
        XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: 'image_${_currentIndex + 1}.png',
        ),
      ]);
    } catch (e) {
      // fallback: copy base64 to clipboard
      try {
        final bytes = widget.images[_currentIndex];
        final base64 = base64Encode(bytes);
        await Clipboard.setData(ClipboardData(text: base64));
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Imagem copiada para a área de transferência (base64)',
              ),
            ),
          );
      } catch (_) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível compartilhar')),
          );
      }
    }
  }

  Future<void> _deleteCurrent() async {
    if (widget.photoIds == null) return;
    final id = widget.photoIds![_currentIndex];
    if (id <= 0) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não é possível excluir esta foto')),
        );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir foto'),
        content: const Text('Deseja realmente excluir esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await HistoriaFotoHelper().deleteFoto(id);
      if (!mounted) return;
      Navigator.of(context).pop(true); // signal deletion happened to caller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Fechar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${_currentIndex + 1} / ${widget.images.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar',
            onPressed: _shareCurrent,
          ),
          if (widget.photoIds != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Excluir foto',
              onPressed: _deleteCurrent,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return Semantics(
                label: 'Imagem ${index + 1} de ${widget.images.length}',
                child: InteractiveViewer(
                  child: Center(
                    child: Image.memory(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),

          // Left arrow
          if (_currentIndex > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                iconSize: 46,
                color: Colors.white70,
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final prev = (_currentIndex - 1).clamp(
                    0,
                    widget.images.length - 1,
                  );
                  _controller.animateToPage(
                    prev,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),

          // Right arrow
          if (_currentIndex < widget.images.length - 1)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                iconSize: 46,
                color: Colors.white70,
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final next = (_currentIndex + 1).clamp(
                    0,
                    widget.images.length - 1,
                  );
                  _controller.animateToPage(
                    next,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),

          // Dots indicator (bottom center)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (i) {
                final active = i == _currentIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 10 : 6,
                  height: active ? 10 : 6,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
