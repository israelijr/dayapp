import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart' as fw;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
// printing not needed in this file
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  }) async {
    final doc = pw.Document();

    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // Usa fontes básicas do PDF. Para emojis temos um fallback bitmap.
    final pw.Font baseFont = pw.Font.helvetica();
    final pw.Font boldFont = pw.Font.helveticaBold();

    // Limites de página (considera margens)
    final pageFormat = pdf.PdfPageFormat.a4;
    const marginAll = 24.0;
    final horizontalMargin = marginAll * 2; // left + right
    final verticalMargin = marginAll * 2; // top + bottom
    final maxImageWidth = pageFormat.width - horizontalMargin;
    final maxImageHeight =
        pageFormat.height -
        verticalMargin -
        120; // reserva espaço para header/text

    // Pré-comprimir/redimensionar imagens assincronamente para evitar que
    // o layout do PDF estoure a altura da página ou consuma muita memória.
    List<Uint8List> compressedImages = [];
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

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(marginAll),
        build: (context) {
          final List<pw.Widget> widgets = [];

          // Header: título e meta
          widgets.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        title,
                        style: pw.TextStyle(font: boldFont, fontSize: 20),
                      ),
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
                pw.SizedBox(height: 6),
                pw.Text(
                  'Data: $dateStr',
                  style: pw.TextStyle(
                    font: baseFont,
                    fontSize: 10,
                    color: pdf.PdfColor.fromInt(0xFF666666),
                  ),
                ),
                if (tags != null && tags.isNotEmpty)
                  pw.Text(
                    'Tags: $tags',
                    style: pw.TextStyle(
                      font: baseFont,
                      fontSize: 10,
                      color: pdf.PdfColor.fromInt(0xFF666666),
                    ),
                  ),
                pw.Divider(),
              ],
            ),
          );

          // Conteúdo textual
          widgets.add(pw.SizedBox(height: 8));
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
  if (byteData == null)
    throw StateError('Não foi possível gerar PNG do emoticon');
  return byteData.buffer.asUint8List();
}
