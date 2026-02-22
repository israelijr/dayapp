import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Tela que mostra um preview do PDF gerado e fornece ações: Compartilhar, Salvar, Fechar.
class PdfPreviewScreen extends StatefulWidget {
  final Uint8List? initialPdfBytes;
  final Future<Uint8List> Function(bool highQuality)? onGenerate;
  final String filename;
  final String title;
  final Future<bool> Function()? onSave; // Retorna true se salvo com sucesso

  const PdfPreviewScreen({
    required this.filename,
    required this.title,
    this.initialPdfBytes,
    this.onGenerate,
    this.onSave,
    super.key,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = false;
  bool _highQuality = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPdfBytes != null) {
      _pdfBytes = widget.initialPdfBytes;
    } else if (widget.onGenerate != null) {
      _generate(_highQuality);
    }
  }

  Future<void> _generate(bool highQuality) async {
    if (widget.onGenerate == null) return;
    setState(() => _isLoading = true);
    try {
      final bytes = await widget.onGenerate!(highQuality);
      if (mounted) setState(() => _pdfBytes = bytes);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          SizedBox(
            width: 170,
            child: Row(
              children: [
                Text(
                  'Alta qualidade',
                  style: TextStyle(
                    color: isDark ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7) : Colors.black87,
                  ),
                ),
                Switch.adaptive(
                  value: _highQuality,
                  onChanged: (v) async {
                    setState(() => _highQuality = v);
                    await _generate(_highQuality);
                  },
                  activeThumbColor: isDark ? Colors.white : Colors.black,
                  activeTrackColor: isDark ? Colors.white24 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.26),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ],
            ),
          ),
          if (widget.onSave != null)
            TextButton(
              onPressed: _pdfBytes == null || _isLoading
                  ? null
                  : () async {
                      final ok = await widget.onSave!();
                      if (ok) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('História salva com sucesso.'),
                            ),
                          );
                        }
                      }
                    },
              // Remover cor fixa para respeitar o tema (claro/escuro).
              child: const Text('Salvar'),
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _pdfBytes == null
                ? null
                : () async {
                    await Printing.sharePdf(
                      bytes: _pdfBytes!,
                      filename: widget.filename,
                    );
                  },
            tooltip: 'Compartilhar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_pdfBytes == null
                ? const Center(child: Text('Nenhum PDF disponível'))
                : PdfPreview(
                    build: (format) async => _pdfBytes!,
                    scrollViewDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    useActions: false,
                  )),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Compartilhar'),
                      onPressed: _pdfBytes == null
                          ? null
                          : () async {
                              await Printing.sharePdf(
                                bytes: _pdfBytes!,
                                filename: widget.filename,
                              );
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
