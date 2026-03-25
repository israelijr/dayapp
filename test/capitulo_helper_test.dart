import 'package:dayapp/db/capitulo_helper.dart';
import 'package:dayapp/db/database_helper.dart';
import 'package:dayapp/models/capitulo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CapituloHelper', () {
    late Database db;
    late CapituloHelper helper;

    Future<void> clearDatabase() async {
      // Ordem importante para respeitar FKs.
      await db.delete('capitulo_entradas');
      await db.delete('capitulos');
      await db.delete('capitulo_sugestoes_ignoradas');
      await db.delete('historia_tags');
      await db.delete('historia_fotos');
      await db.delete('historia_audios');
      await db.delete('historia_videos');
      await db.delete('notification_scheduled');
      await db.delete('historia');
      await db.delete('tags');
      await db.delete('grupos');
      await db.delete('users');
    }

    Future<void> insertUser(String userId) async {
      await db.insert('users', {
        'id': userId,
        'nome': 'Usuário Teste',
        'email': '$userId@test.dev',
        'senha': 'hash',
      });
    }

    Future<int> insertHistoria({
      required String userId,
      required DateTime data,
      required String titulo,
      String? excluido,
    }) async {
      return db.insert('historia', {
        'user_id': userId,
        'titulo': titulo,
        'data': data.toIso8601String(),
        'excluido': excluido,
      });
    }

    setUp(() async {
      helper = CapituloHelper();
      db = await DatabaseHelper().database;
      await clearDatabase();
    });

    test(
      'addEntradaToCapitulo atualiza data_inicio/data_fim e ignora duplicado',
      () async {
        const userId = 'u_cap_1';
        await insertUser(userId);

        final entradaRecente = await insertHistoria(
          userId: userId,
          data: DateTime(2026, 3, 20),
          titulo: 'Entrada recente',
        );
        final entradaAntiga = await insertHistoria(
          userId: userId,
          data: DateTime(2026, 3, 10),
          titulo: 'Entrada antiga',
        );

        final capituloId = await helper.insertCapituloWithEntradas(
          Capitulo(
            userId: userId,
            titulo: 'Capítulo de teste',
            descricao: null,
            dataInicio: DateTime(2026, 3, 20),
            dataFim: DateTime(2026, 3, 20),
            criadoAutomaticamente: false,
          ),
          [entradaRecente],
        );

        await helper.addEntradaToCapitulo(
          capituloId: capituloId,
          entradaId: entradaAntiga,
        );

        // Repetição deve ser ignorada pelo UNIQUE(capitulo_id, entrada_id).
        await helper.addEntradaToCapitulo(
          capituloId: capituloId,
          entradaId: entradaAntiga,
        );

        final capituloRows = await db.query(
          'capitulos',
          where: 'id = ?',
          whereArgs: [capituloId],
        );

        expect(capituloRows, hasLength(1));
        expect(
          DateTime.parse(capituloRows.first['data_inicio'] as String),
          DateTime(2026, 3, 10),
        );
        expect(
          DateTime.parse(capituloRows.first['data_fim'] as String),
          DateTime(2026, 3, 20),
        );

        final relacoes = await db.query(
          'capitulo_entradas',
          where: 'capitulo_id = ?',
          whereArgs: [capituloId],
        );
        expect(relacoes, hasLength(2));
      },
    );

    test(
      'getHistoriasByIds retorna em ordem ascendente e exclui deletadas',
      () async {
        const userId = 'u_cap_2';
        await insertUser(userId);

        final id1 = await insertHistoria(
          userId: userId,
          data: DateTime(2026, 1, 1),
          titulo: 'Primeira',
        );
        final id2 = await insertHistoria(
          userId: userId,
          data: DateTime(2026, 1, 2),
          titulo: 'Segunda deletada',
          excluido: 'sim',
        );
        final id3 = await insertHistoria(
          userId: userId,
          data: DateTime(2026, 1, 3),
          titulo: 'Terceira',
        );

        final historias = await helper.getHistoriasByIds([id3, id2, id1]);

        expect(historias.map((h) => h.id).toList(), [id1, id3]);
        expect(historias.map((h) => h.titulo).toList(), [
          'Primeira',
          'Terceira',
        ]);
      },
    );

    test(
      'listEntradasElegiveis retorna apenas não deletadas em ordem desc',
      () async {
        const userId = 'u_cap_3';
        await insertUser(userId);

        await insertHistoria(
          userId: userId,
          data: DateTime(2026, 2, 1),
          titulo: 'Mais antiga',
        );
        await insertHistoria(
          userId: userId,
          data: DateTime(2026, 2, 2),
          titulo: 'Deletada',
          excluido: 'sim',
        );
        await insertHistoria(
          userId: userId,
          data: DateTime(2026, 2, 3),
          titulo: 'Mais recente',
        );

        final elegiveis = await helper.listEntradasElegiveis(userId);

        expect(elegiveis.map((h) => h.titulo).toList(), [
          'Mais recente',
          'Mais antiga',
        ]);
      },
    );
  });
}
