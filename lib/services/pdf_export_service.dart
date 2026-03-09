import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' as fw;
// printing not needed in this file
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

/// Serviço para gerar PDF a partir de dados de uma história.
/// Comentários e nomes em português conforme convenção do projeto.
class PdfExportService {
  /// Gera um PDF contendo título, data, emoticon, tags, texto e imagens.
  /// Retorna os bytes do PDF prontos para salvar/compartilhar.
  static Future<Uint8List> generatePdfFromHistoria({
    required String title,
    required String content,
    required DateTime date,
    List<Uint8List>? images,
    String? tags,
    String? emoticon,
    bool highQuality = false,
    String? locale,
  }) async {
    final doc = pw.Document();

    // Formata a data conforme o locale selecionado no app
    final resolvedLocale = locale ?? 'pt_BR';
    await initializeDateFormatting(resolvedLocale, null);
    final dateStr = DateFormat.yMd(resolvedLocale).add_Hm().format(date);

    // Tenta carregar fontes TTF (Noto) em assets para suporte Unicode.
    // Se não existir, mantém o fallback para Helvetica (sem suporte Unicode).
    pw.Font baseFont;
    pw.Font boldFont;
    try {
      final bd = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final bytes = bd.buffer.asUint8List();
      // Verifica se o arquivo carregado tem um cabeçalho compatível com
      // TTF/OTF/TrueType Collection para evitar erro de parsing mais
      // adiante quando o PDF tentar construir a fonte.
      if (!_looksLikeTtf(bytes)) {
        throw const FormatException('Arquivo de fonte inválido');
      }
      baseFont = pw.Font.ttf(bd);
    } catch (_) {
      baseFont = pw.Font.helvetica();
    }
    try {
      final bd = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      final bytes = bd.buffer.asUint8List();
      if (!_looksLikeTtf(bytes)) {
        throw const FormatException('Arquivo de fonte inválido');
      }
      boldFont = pw.Font.ttf(bd);
    } catch (_) {
      boldFont = pw.Font.helveticaBold();
    }

    // Limites de página (considera margens)
    const pageFormat = pdf.PdfPageFormat.a4;
    const marginAll = 24.0;
    const horizontalMargin = marginAll * 2; // left + right
    const verticalMargin = marginAll * 2; // top + bottom
    final maxImageWidth = pageFormat.width - horizontalMargin;
    final maxImageHeight =
        pageFormat.height -
        verticalMargin -
        120; // reserva espaço para header/text

    // Pré-comprimir/redimensionar imagens assincronamente para evitar que
    // o layout do PDF estoure a altura da página ou consuma muita memória.
    final List<Uint8List> compressedImages = [];
    if (images != null && images.isNotEmpty) {
      final int cap = highQuality ? 2000 : 1200;
      final int maxWidthPx = math.min((maxImageWidth * 2).toInt(), cap);
      final int quality = highQuality ? 95 : 80;
      for (final img in images) {
        try {
          final compressed = await FlutterImageCompress.compressWithList(
            img,
            minWidth: maxWidthPx,
            quality: quality,
            rotate: 0,
          );
          if (compressed.isNotEmpty) {
            compressedImages.add(compressed);
          } else {
            compressedImages.add(img);
          }
        } catch (_) {
          compressedImages.add(img);
        }
      }
    }

    // Renderiza o emoticon como PNG pequeno usando TextPainter para garantir
    // que mesmo que a fonte embutida do PDF não contenha o glifo, teremos
    // uma representação visual (bitmap) que será incorporada no PDF.
    Uint8List? emoticonPng;
    if (emoticon != null && emoticon.isNotEmpty) {
      try {
        emoticonPng = await _renderEmojiToPng(emoticon, 28);
      } catch (_) {
        emoticonPng = null;
      }
    }

    // Carrega o ícone do app para o cabeçalho do PDF
    Uint8List? iconBytes;
    try {
      final iconData = await rootBundle.load('assets/icon/icon.png');
      iconBytes = iconData.buffer.asUint8List();
    } catch (_) {
      iconBytes = null;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(marginAll),
        build: (context) {
          final List<pw.Widget> widgets = [];

          // Cabeçalho da marca DayApp
          widgets.add(
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (iconBytes != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(right: 8),
                    child: pw.Image(
                      pw.MemoryImage(iconBytes),
                      width: 36,
                      height: 36,
                    ),
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DayApp',
                      style: pw.TextStyle(font: boldFont, fontSize: 18),
                    ),
                    pw.Text(
                      'Seu diário pessoal',
                      style: pw.TextStyle(
                        font: baseFont,
                        fontSize: 10,
                        color: const pdf.PdfColor.fromInt(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 8));
          widgets.add(pw.Divider());
          widgets.add(pw.SizedBox(height: 8));

          // Título da história
          widgets.add(
            pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 20)),
          );

          widgets.add(pw.SizedBox(height: 6));

          // Linha com data/hora à esquerda e emoticon à direita
          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      dateStr,
                      style: pw.TextStyle(
                        font: baseFont,
                        fontSize: 10,
                        color: const pdf.PdfColor.fromInt(0xFF666666),
                      ),
                    ),
                    if (tags != null && tags.isNotEmpty)
                      pw.Text(
                        'Tags: $tags',
                        style: pw.TextStyle(
                          font: baseFont,
                          fontSize: 10,
                          color: const pdf.PdfColor.fromInt(0xFF666666),
                        ),
                      ),
                  ],
                ),
                if (emoticonPng != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(left: 8),
                    child: pw.Image(
                      pw.MemoryImage(emoticonPng),
                      width: 26,
                      height: 26,
                    ),
                  )
                else if (emoticon != null)
                  pw.Text(
                    emoticon,
                    style: pw.TextStyle(font: baseFont, fontSize: 20),
                  ),
              ],
            ),
          );

          // Conteúdo textual
          widgets.add(pw.SizedBox(height: 16));
          widgets.add(
            pw.Text(content, style: pw.TextStyle(font: baseFont, fontSize: 12)),
          );

          // Imagens (uma por linha, redimensionadas)
          if (compressedImages.isNotEmpty) {
            widgets.add(pw.SizedBox(height: 12));
            widgets.add(
              pw.Text(
                'Imagens',
                style: pw.TextStyle(font: boldFont, fontSize: 14),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (final img in compressedImages) {
              try {
                final pwImage = pw.MemoryImage(img);

                // Ajusta largura máxima e altura máxima, preservando proporção.
                widgets.add(
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Center(
                      child: pw.Image(
                        pwImage,
                        fit: pw.BoxFit.contain,
                        width: math.min(maxImageWidth, 450),
                        height: math.min(maxImageHeight, 800),
                      ),
                    ),
                  ),
                );
              } catch (_) {
                // Ignora imagem que não puder ser inserida
              }
            }
          }

          return widgets;
        },
      ),
    );

    return doc.save();
  }
}

// Verifica de forma simples os primeiros bytes para identificar formatos
// TTF/OTF/TTF Collection. Retorna `true` se o cabeçalho corresponder a
// uma das assinaturas conhecidas: 0x00010000 (TTF), 'OTTO' (OpenType),
// 'ttcf' (TrueType Collection).
bool _looksLikeTtf(Uint8List bytes) {
  if (bytes.length < 4) return false;
  // 00 01 00 00
  if (bytes[0] == 0x00 &&
      bytes[1] == 0x01 &&
      bytes[2] == 0x00 &&
      bytes[3] == 0x00) {
    return true;
  }
  // 'OTTO'
  if (bytes[0] == 0x4F &&
      bytes[1] == 0x54 &&
      bytes[2] == 0x54 &&
      bytes[3] == 0x4F) {
    return true;
  }
  // 'ttcf'
  if (bytes[0] == 0x74 &&
      bytes[1] == 0x74 &&
      bytes[2] == 0x63 &&
      bytes[3] == 0x66) {
    return true;
  }
  return false;
}

/// Renderiza um emoji/emoji-like `String` para PNG usando `TextPainter`.
/// Retorna `Uint8List` com bytes PNG ou lança se houver erro.
Future<Uint8List> _renderEmojiToPng(String emoji, double size) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  final textSpan = fw.TextSpan(
    text: emoji,
    style: fw.TextStyle(fontSize: size),
  );
  final tp = fw.TextPainter(
    text: textSpan,
    textDirection: fw.TextDirection.ltr,
  );
  tp.layout();

  tp.paint(canvas, const ui.Offset(0, 0));

  final picture = recorder.endRecording();
  final img = await picture.toImage(tp.width.ceil(), tp.height.ceil());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Não foi possível gerar PNG do emoticon');
  }
  return byteData.buffer.asUint8List();
}
