import 'dart:typed_data';

import '../models/historia_audio.dart';
import 'database_helper.dart';

class HistoriaAudioHelper {
  Future<int> insertAudio(HistoriaAudio audio) async {
    final db = await DatabaseHelper().database;
    // Converte para Uint8List se necessário
    final audioBytes = audio.audio is Uint8List
        ? audio.audio
        : Uint8List.fromList(audio.audio);
    return await db.insert('historia_audios', {
      'historia_id': audio.historiaId,
      'audio': audioBytes,
      'legenda': audio.legenda,
      'duracao': audio.duracao,
    });
  }

  Future<List<HistoriaAudio>> getAudiosByHistoria(int historiaId) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia_audios',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );
    return result.map((map) => HistoriaAudio.fromMap(map)).toList();
  }

  Future<int> deleteAudio(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('historia_audios', where: 'id = ?', whereArgs: [id]);
  }
}
