import 'dart:typed_data';

class HistoriaAudio {
  final int? id;
  final int historiaId;
  final List<int> audio;
  final String? legenda;
  final int? duracao; // duração em segundos

  HistoriaAudio({
    required this.historiaId, required this.audio, this.id,
    this.legenda,
    this.duracao,
  });

  factory HistoriaAudio.fromMap(Map<String, dynamic> map) {
    // Garante que o BLOB seja convertido para List<int>
    final audioData = map['audio'];
    List<int> audioBytes;
    if (audioData is Uint8List) {
      audioBytes = audioData;
    } else if (audioData is List<int>) {
      audioBytes = audioData;
    } else if (audioData is List<dynamic>) {
      audioBytes = audioData.cast<int>();
    } else {
      audioBytes = [];
    }
    return HistoriaAudio(
      id: map['id'],
      historiaId: map['historia_id'],
      audio: audioBytes,
      legenda: map['legenda'],
      duracao: map['duracao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'historia_id': historiaId,
      'audio': audio,
      'legenda': legenda,
      'duracao': duracao,
    };
  }
}
