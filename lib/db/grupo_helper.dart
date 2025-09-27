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
}
