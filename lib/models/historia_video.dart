import 'dart:typed_data';

class HistoriaVideo {
  final int? id;
  final int historiaId;
  final List<int> video;
  final String? legenda;
  final int? duracao; // duração em segundos
  final List<int>? thumbnail; // miniatura do vídeo

  HistoriaVideo({
    this.id,
    required this.historiaId,
    required this.video,
    this.legenda,
    this.duracao,
    this.thumbnail,
  });

  factory HistoriaVideo.fromMap(Map<String, dynamic> map) {
    // Garante que o BLOB seja convertido para List<int>
    final videoData = map['video'];
    List<int> videoBytes;
    if (videoData is Uint8List) {
      videoBytes = videoData;
    } else if (videoData is List<int>) {
      videoBytes = videoData;
    } else if (videoData is List<dynamic>) {
      videoBytes = videoData.cast<int>();
    } else {
      videoBytes = [];
    }

    // Processa thumbnail se existir
    List<int>? thumbnailBytes;
    final thumbnailData = map['thumbnail'];
    if (thumbnailData != null) {
      if (thumbnailData is Uint8List) {
        thumbnailBytes = thumbnailData;
      } else if (thumbnailData is List<int>) {
        thumbnailBytes = thumbnailData;
      } else if (thumbnailData is List<dynamic>) {
        thumbnailBytes = thumbnailData.cast<int>();
      }
    }

    return HistoriaVideo(
      id: map['id'],
      historiaId: map['historia_id'],
      video: videoBytes,
      legenda: map['legenda'],
      duracao: map['duracao'],
      thumbnail: thumbnailBytes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'historia_id': historiaId,
      'video': video,
      'legenda': legenda,
      'duracao': duracao,
      'thumbnail': thumbnail,
    };
  }
}
