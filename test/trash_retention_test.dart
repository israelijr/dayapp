import 'package:dayapp/db/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Trash retention', () {
    late Database db;

    setUp(() async {
      db = await openDatabase(
        ':memory:',
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE historia (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL,
              titulo TEXT NOT NULL,
              data TIMESTAMP NOT NULL,
              excluido TEXT,
              data_exclusao TIMESTAMP
            );
          ''');
        },
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'deve remover somente histórias excluídas há 30 dias ou mais',
      () async {
        final now = DateTime(2026, 3, 20, 12);

        // História ativa nunca deve ser removida pela limpeza da lixeira.
        await db.insert('historia', {
          'user_id': 'user_1',
          'titulo': 'Ativa',
          'data': now.toIso8601String(),
          'excluido': null,
          'data_exclusao': null,
        });

        // Excluída recentemente (10 dias) deve permanecer.
        await db.insert('historia', {
          'user_id': 'user_1',
          'titulo': 'Recente',
          'data': now.toIso8601String(),
          'excluido': 'sim',
          'data_exclusao': now
              .subtract(const Duration(days: 10))
              .toIso8601String(),
        });

        // Excluída exatamente há 30 dias deve ser removida.
        await db.insert('historia', {
          'user_id': 'user_1',
          'titulo': 'Limite',
          'data': now.toIso8601String(),
          'excluido': 'sim',
          'data_exclusao': now
              .subtract(const Duration(days: 30))
              .toIso8601String(),
        });

        // Excluída há 31 dias deve ser removida.
        await db.insert('historia', {
          'user_id': 'user_1',
          'titulo': 'Expirada',
          'data': now.toIso8601String(),
          'excluido': 'sim',
          'data_exclusao': now
              .subtract(const Duration(days: 31))
              .toIso8601String(),
        });

        final removedCount =
            await DatabaseHelper.deleteExpiredTrashStoriesFromDatabase(
              db,
              userId: 'user_1',
              retentionDays: 30,
              now: now,
            );

        expect(removedCount, 2);

        final remaining = await db.query('historia', orderBy: 'id ASC');

        final remainingTitles = remaining
            .map((row) => row['titulo'] as String)
            .toList();

        expect(remainingTitles, ['Ativa', 'Recente']);
      },
    );

    test('deve limpar apenas histórias do usuário informado', () async {
      final now = DateTime(2026, 3, 20, 12);

      await db.insert('historia', {
        'user_id': 'user_1',
        'titulo': 'Expirada user_1',
        'data': now.toIso8601String(),
        'excluido': 'sim',
        'data_exclusao': now
            .subtract(const Duration(days: 40))
            .toIso8601String(),
      });

      await db.insert('historia', {
        'user_id': 'user_2',
        'titulo': 'Expirada user_2',
        'data': now.toIso8601String(),
        'excluido': 'sim',
        'data_exclusao': now
            .subtract(const Duration(days: 40))
            .toIso8601String(),
      });

      final removedCount =
          await DatabaseHelper.deleteExpiredTrashStoriesFromDatabase(
            db,
            userId: 'user_1',
            retentionDays: 30,
            now: now,
          );

      expect(removedCount, 1);

      final remaining = await db.query('historia');
      expect(remaining.length, 1);
      expect(remaining.first['user_id'], 'user_2');
    });
  });
}
