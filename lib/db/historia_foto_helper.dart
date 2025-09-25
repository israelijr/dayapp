import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/historia_foto.dart';

class HistoriaFotoHelper {
  Future<int> insertFoto(HistoriaFoto foto) async {
    final db = await DatabaseHelper().database;
    // Converte para Uint8List se necessário
    final fotoBytes = foto.foto is Uint8List
        ? foto.foto
        : Uint8List.fromList(foto.foto);
    return await db.insert('historia_fotos', {
      'historia_id': foto.historiaId,
      'foto': fotoBytes,
      'legenda': foto.legenda,
    });
  }

  Future<List<HistoriaFoto>> getFotosByHistoria(int historiaId) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia_fotos',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );
    return result.map((map) => HistoriaFoto.fromMap(map)).toList();
  }
}
