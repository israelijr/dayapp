import 'dart:typed_data';

class HistoriaFoto {
  final int? id;
  final int historiaId;
  final List<int> foto;
  final String? legenda;

  HistoriaFoto({
    required this.historiaId, required this.foto, this.id,
    this.legenda,
  });

  factory HistoriaFoto.fromMap(Map<String, dynamic> map) {
    // Garante que o BLOB seja convertido para List<int>
    final fotoData = map['foto'];
    List<int> fotoBytes;
    if (fotoData is Uint8List) {
      fotoBytes = fotoData;
    } else if (fotoData is List<int>) {
      fotoBytes = fotoData;
    } else if (fotoData is List<dynamic>) {
      fotoBytes = fotoData.cast<int>();
    } else {
      fotoBytes = [];
    }
    return HistoriaFoto(
      id: map['id'],
      historiaId: map['historia_id'],
      foto: fotoBytes,
      legenda: map['legenda'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'historia_id': historiaId,
      'foto': foto,
      'legenda': legenda,
    };
  }
}
