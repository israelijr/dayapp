import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Widget que renderiza texto como Markdown se tiver sintaxe, ou como texto simples
class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const MarkdownText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
  });

  /// Verifica se o texto contém sintaxe Markdown
  bool _hasMarkdown(String text) {
    // Verifica padrões comuns de markdown
    return text.contains(RegExp(r'\*\*.*\*\*')) || // negrito
        text.contains(RegExp(r'\*.*\*')) || // itálico
        text.contains(RegExp(r'~~.*~~')) || // tachado
        text.contains(RegExp(r'^#+\s', multiLine: true)) || // títulos
        text.contains(RegExp(r'^-\s', multiLine: true)) || // lista
        text.contains(RegExp(r'^\d+\.\s', multiLine: true)) || // lista numerada
        text.contains(RegExp(r'^>\s', multiLine: true)) || // citação
        text.contains(RegExp(r'`.*`')); // código
  }

  @override
  Widget build(BuildContext context) {
    if (_hasMarkdown(text)) {
      // Renderizar como Markdown
      return MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet(
          p: style,
          textScaler: TextScaler.linear(
            style?.fontSize != null ? style!.fontSize! / 14.0 : 1.0,
          ),
        ),
        fitContent: true,
        shrinkWrap: true,
      );
    } else {
      // Renderizar como texto simples
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }
  }
}
