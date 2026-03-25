import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> _createLegacyV16Schema(Database db) async {
  await db.execute('''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      nome TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      senha TEXT NOT NULL
    );
  ''');

  await db.execute('''
    CREATE TABLE historia (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      titulo TEXT NOT NULL,
      data TIMESTAMP NOT NULL,
      excluido TEXT,
      humor INTEGER DEFAULT 3,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
  ''');
}

Future<void> _applyV17Migration(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS capitulos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      titulo TEXT NOT NULL,
      descricao TEXT,
      data_inicio TIMESTAMP NOT NULL,
      data_fim TIMESTAMP NOT NULL,
      score_confianca REAL,
      criado_automaticamente INTEGER DEFAULT 0,
      data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      data_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS capitulo_entradas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      capitulo_id INTEGER NOT NULL,
      entrada_id INTEGER NOT NULL,
      UNIQUE(capitulo_id, entrada_id),
      FOREIGN KEY (capitulo_id) REFERENCES capitulos(id) ON DELETE CASCADE,
      FOREIGN KEY (entrada_id) REFERENCES historia(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS capitulo_sugestoes_ignoradas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      fingerprint TEXT NOT NULL,
      data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(user_id, fingerprint),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
  ''');

  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_capitulos_user_data ON capitulos(user_id, data_inicio, data_fim);',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_capitulo_entradas_capitulo ON capitulo_entradas(capitulo_id);',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_capitulo_entradas_entrada ON capitulo_entradas(entrada_id);',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_capitulo_sugestoes_user ON capitulo_sugestoes_ignoradas(user_id);',
  );
}

Future<bool> _existsInSqliteMaster(
  Database db,
  String type,
  String name,
) async {
  final rows = await db.query(
    'sqlite_master',
    columns: ['name'],
    where: 'type = ? AND name = ?',
    whereArgs: [type, name],
  );
  return rows.isNotEmpty;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Migração de capítulos v17', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('dayapp_migration_');
      dbPath = p.join(tempDir.path, 'dayapp_migration.db');

      final dbV16 = await openDatabase(
        dbPath,
        version: 16,
        onCreate: (db, version) async {
          await _createLegacyV16Schema(db);
        },
      );
      await dbV16.close();
    });

    tearDown(() async {
      try {
        await deleteDatabase(dbPath);
      } catch (_) {
        // Ignora falha de cleanup para não mascarar o teste principal.
      }
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'cria tabelas e indices de capítulos ao migrar de 16 para 17',
      () async {
        final dbV17 = await openDatabase(
          dbPath,
          version: 17,
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 17) {
              await _applyV17Migration(db);
            }
          },
        );

        expect(
          await _existsInSqliteMaster(dbV17, 'table', 'capitulos'),
          isTrue,
        );
        expect(
          await _existsInSqliteMaster(dbV17, 'table', 'capitulo_entradas'),
          isTrue,
        );
        expect(
          await _existsInSqliteMaster(
            dbV17,
            'table',
            'capitulo_sugestoes_ignoradas',
          ),
          isTrue,
        );

        expect(
          await _existsInSqliteMaster(
            dbV17,
            'index',
            'idx_capitulos_user_data',
          ),
          isTrue,
        );
        expect(
          await _existsInSqliteMaster(
            dbV17,
            'index',
            'idx_capitulo_entradas_capitulo',
          ),
          isTrue,
        );
        expect(
          await _existsInSqliteMaster(
            dbV17,
            'index',
            'idx_capitulo_entradas_entrada',
          ),
          isTrue,
        );
        expect(
          await _existsInSqliteMaster(
            dbV17,
            'index',
            'idx_capitulo_sugestoes_user',
          ),
          isTrue,
        );

        await dbV17.close();
      },
    );

    test('permite uso normal da estrutura após migração', () async {
      final dbV17 = await openDatabase(
        dbPath,
        version: 17,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 17) {
            await _applyV17Migration(db);
          }
        },
      );

      await dbV17.insert('users', {
        'id': 'u1',
        'nome': 'Teste',
        'email': 'teste@dayapp.dev',
        'senha': 'hash',
      });

      final historiaId = await dbV17.insert('historia', {
        'user_id': 'u1',
        'titulo': 'Entrada de teste',
        'data': DateTime(2026, 3, 10).toIso8601String(),
        'humor': 4,
      });

      final capituloId = await dbV17.insert('capitulos', {
        'user_id': 'u1',
        'titulo': 'Fase de Teste',
        'descricao': null,
        'data_inicio': DateTime(2026, 3, 1).toIso8601String(),
        'data_fim': DateTime(2026, 3, 31).toIso8601String(),
        'criado_automaticamente': 0,
      });

      await dbV17.insert('capitulo_entradas', {
        'capitulo_id': capituloId,
        'entrada_id': historiaId,
      });

      final rows = await dbV17.rawQuery(
        '''
        SELECT c.titulo, ce.entrada_id
        FROM capitulos c
        JOIN capitulo_entradas ce ON ce.capitulo_id = c.id
        WHERE c.id = ?
        ''',
        [capituloId],
      );

      expect(rows.length, 1);
      expect(rows.first['titulo'], 'Fase de Teste');
      expect(rows.first['entrada_id'], historiaId);

      await dbV17.close();
    });
  });
}
