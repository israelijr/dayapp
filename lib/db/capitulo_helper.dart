import 'package:sqflite/sqflite.dart';

import '../models/capitulo.dart';
import '../models/historia.dart';
import 'database_helper.dart';

class CapituloHelper {
  Future<int> insertCapituloWithEntradas(
    Capitulo capitulo,
    List<int> entradaIds,
  ) async {
    final db = await DatabaseHelper().database;
    return db.transaction((txn) async {
      final capituloId = await txn.insert('capitulos', {
        ...capitulo.toMap(),
        'data_update': DateTime.now().toIso8601String(),
      });

      for (final entradaId in entradaIds.toSet()) {
        await txn.insert('capitulo_entradas', {
          'capitulo_id': capituloId,
          'entrada_id': entradaId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      return capituloId;
    });
  }

  Future<void> updateCapituloWithEntradas(
    Capitulo capitulo,
    List<int> entradaIds,
  ) async {
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      await txn.update(
        'capitulos',
        {...capitulo.toMap(), 'data_update': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [capitulo.id],
      );

      await txn.delete(
        'capitulo_entradas',
        where: 'capitulo_id = ?',
        whereArgs: [capitulo.id],
      );

      for (final entradaId in entradaIds.toSet()) {
        await txn.insert('capitulo_entradas', {
          'capitulo_id': capitulo.id,
          'entrada_id': entradaId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  Future<List<CapituloResumo>> getCapitulosResumoByUser(String userId) async {
    final db = await DatabaseHelper().database;

    final rows = await db.rawQuery(
      '''
      SELECT
        c.*,
        COUNT(ce.entrada_id) AS total_entradas,
        COALESCE(AVG(h.humor), 3.0) AS humor_medio
      FROM capitulos c
      LEFT JOIN capitulo_entradas ce ON ce.capitulo_id = c.id
      LEFT JOIN historia h ON h.id = ce.entrada_id
      WHERE c.user_id = ?
      GROUP BY c.id
      ORDER BY c.data_inicio DESC
      ''',
      [userId],
    );

    final result = <CapituloResumo>[];
    for (final row in rows) {
      final capitulo = Capitulo.fromMap(row);
      final topTagsRows = await db.rawQuery(
        '''
        SELECT t.nome, COUNT(*) as total
        FROM capitulo_entradas ce
        JOIN historia_tags ht ON ht.historia_id = ce.entrada_id
        JOIN tags t ON t.id = ht.tag_id
        WHERE ce.capitulo_id = ?
        GROUP BY t.id, t.nome
        ORDER BY total DESC, t.nome ASC
        LIMIT 3
        ''',
        [capitulo.id],
      );

      result.add(
        CapituloResumo(
          capitulo: capitulo,
          totalEntradas: (row['total_entradas'] as int?) ?? 0,
          humorMedio: (row['humor_medio'] as num?)?.toDouble() ?? 3.0,
          topTags: topTagsRows
              .map((tagRow) => tagRow['nome'] as String)
              .toList(growable: false),
        ),
      );
    }

    return result;
  }

  Future<List<Historia>> getEntradasByCapitulo(int capituloId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT h.*
      FROM capitulo_entradas ce
      JOIN historia h ON h.id = ce.entrada_id
      WHERE ce.capitulo_id = ?
        AND h.excluido IS NULL
      ORDER BY h.data DESC
      ''',
      [capituloId],
    );

    return rows.map((row) => Historia.fromMap(row)).toList(growable: false);
  }

  Future<void> deleteCapitulo(int capituloId) async {
    final db = await DatabaseHelper().database;
    await db.delete('capitulos', where: 'id = ?', whereArgs: [capituloId]);
  }

  Future<List<Historia>> listEntradasElegiveis(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'historia',
      where: 'user_id = ? AND excluido IS NULL',
      whereArgs: [userId],
      orderBy: 'data DESC',
      columns: [
        'id',
        'user_id',
        'assunto',
        'titulo',
        'data',
        'tag',
        'grupo',
        'arquivado',
        'excluido',
        'data_exclusao',
        'descricao',
        'sentimento',
        'emoticon',
        'data_criacao',
        'data_update',
        'foto_historia',
        'backed_up',
        'humor',
        'energia',
      ],
    );

    return rows.map((row) => Historia.fromMap(row)).toList(growable: false);
  }

  Future<void> ignoreSuggestion({
    required String userId,
    required String fingerprint,
  }) async {
    final db = await DatabaseHelper().database;
    await db.insert('capitulo_sugestoes_ignoradas', {
      'user_id': userId,
      'fingerprint': fingerprint,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Set<String>> getIgnoredSuggestionFingerprints(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'capitulo_sugestoes_ignoradas',
      columns: ['fingerprint'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return rows.map((row) => row['fingerprint'] as String).toSet();
  }

  Future<Set<int>> getEntradasJaVinculadas(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT ce.entrada_id
      FROM capitulo_entradas ce
      JOIN capitulos c ON c.id = ce.capitulo_id
      WHERE c.user_id = ?
      ''',
      [userId],
    );

    return rows.map((row) => row['entrada_id'] as int).toSet();
  }

  Future<void> addEntradaToCapitulo({
    required int capituloId,
    required int entradaId,
  }) async {
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      await txn.insert('capitulo_entradas', {
        'capitulo_id': capituloId,
        'entrada_id': entradaId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      final rows = await txn.rawQuery(
        '''
        SELECT
          MIN(h.data) AS data_inicio,
          MAX(h.data) AS data_fim
        FROM capitulo_entradas ce
        JOIN historia h ON h.id = ce.entrada_id
        WHERE ce.capitulo_id = ?
        ''',
        [capituloId],
      );

      if (rows.isNotEmpty) {
        final row = rows.first;
        final dataInicio = row['data_inicio'] as String?;
        final dataFim = row['data_fim'] as String?;
        if (dataInicio != null && dataFim != null) {
          await txn.update(
            'capitulos',
            {
              'data_inicio': dataInicio,
              'data_fim': dataFim,
              'data_update': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [capituloId],
          );
        }
      }
    });
  }

  Future<List<Historia>> getHistoriasByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];

    final db = await DatabaseHelper().database;
    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await db.query(
      'historia',
      where: 'id IN ($placeholders) AND excluido IS NULL',
      whereArgs: ids,
      orderBy: 'data ASC',
      columns: [
        'id',
        'user_id',
        'assunto',
        'titulo',
        'data',
        'tag',
        'grupo',
        'arquivado',
        'excluido',
        'data_exclusao',
        'descricao',
        'sentimento',
        'emoticon',
        'data_criacao',
        'data_update',
        'foto_historia',
        'backed_up',
        'humor',
        'energia',
      ],
    );

    return rows.map((row) => Historia.fromMap(row)).toList(growable: false);
  }
}
