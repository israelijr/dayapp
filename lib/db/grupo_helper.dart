import 'database_helper.dart';
import '../models/grupo.dart';

class GrupoHelper {
  Future<int> insertGrupo(Grupo grupo) async {
    final db = await DatabaseHelper().database;
    return await db.insert('grupos', grupo.toMap());
  }

  Future<List<Grupo>> getGruposByUser(String userId) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'grupos',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'nome ASC',
    );
    return result.map((map) => Grupo.fromMap(map)).toList();
  }

  Future<Grupo?> getGrupoByNome(String userId, String nome) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'grupos',
      where: 'user_id = ? AND nome = ?',
      whereArgs: [userId, nome],
    );
    if (result.isNotEmpty) {
      return Grupo.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteGrupo(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('grupos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteGrupoAndUpdateHistorias(
    int grupoId,
    String grupoNome,
    String userId,
  ) async {
    final db = await DatabaseHelper().database;
    // Primeiro, atualizar histórias que têm tag igual ao nome do grupo
    await db.update(
      'historia',
      {'tag': null},
      where: 'user_id = ? AND tag = ?',
      whereArgs: [userId, grupoNome],
    );
    // Depois, excluir o grupo
    await db.delete('grupos', where: 'id = ?', whereArgs: [grupoId]);
  }
}
