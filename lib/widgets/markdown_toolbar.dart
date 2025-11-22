import 'package:flutter/material.dart';
import '../helpers/markdown_helper.dart';

/// Botão compacto que abre menu de formatação Markdown
class MarkdownFormattingButton extends StatelessWidget {
  final TextEditingController controller;

  const MarkdownFormattingButton({super.key, required this.controller});

  void _showFormattingMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Formatação Markdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FormatButton(
                  label: 'Negrito',
                  icon: Icons.format_bold,
                  onPressed: () {
                    Navigator.pop(context);
                    MarkdownHelper.wrapSelection(controller, '**', '**');
                  },
                ),
                _FormatButton(
                  label: 'Itálico',
                  icon: Icons.format_italic,
                  onPressed: () {
                    Navigator.pop(context);
                    MarkdownHelper.wrapSelection(controller, '*', '*');
                  },
                ),
                _FormatButton(
                  label: 'Tachado',
                  icon: Icons.format_strikethrough,
                  onPressed: () {
                    Navigator.pop(context);
                    MarkdownHelper.wrapSelection(controller, '~~', '~~');
                  },
                ),
                _FormatButton(
                  label: 'Código',
                  icon: Icons.code,
                  onPressed: () {
                    Navigator.pop(context);
                    MarkdownHelper.wrapSelection(controller, '`', '`');
                  },
                ),
                _FormatButton(
                  label: 'Título',
                  icon: Icons.title,
                  onPressed: () {
                    Navigator.pop(context);
                    MarkdownHelper.formatHeading(controller, 1);
                  },
                ),
                _FormatButton(
                  label: 'Lista',
                  icon: Icons.format_list_bulleted,
                  onPressed: () {
                    Navigator.pop(context);
                    MarkdownHelper.toggleList(controller);
                  },
                ),
                _FormatButton(
                  label: 'Lista Num.',
                  icon: Icons.format_list_numbered,
                  onPressed: () {
                    Navigator.pop(context);
                    MarkdownHelper.toggleList(controller, ordered: true);
                  },
                ),
                _FormatButton(
                  label: 'Citação',
                  icon: Icons.format_quote,
                  onPressed: () {
                    Navigator.pop(context);
                    MarkdownHelper.insertAtCursor(
                      controller,
                      '> ',
                      newLine: true,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.format_size, size: 20),
      onPressed: () => _showFormattingMenu(context),
      tooltip: 'Formatação Markdown',
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _FormatButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
