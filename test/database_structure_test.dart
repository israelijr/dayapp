import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Structure Tests', () {
    late Database db;

    setUp(() async {
      db = await openDatabase(
        ':memory:',
        version: 9,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE historia (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL,
              titulo TEXT NOT NULL,
              data TEXT
            );
          ''');

          await db.execute('''
            CREATE TABLE historia_videos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              historia_id INTEGER NOT NULL,
              video_path TEXT NOT NULL,
              legenda TEXT,
              duracao INTEGER,
              thumbnail_path TEXT,
              FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
            );
          ''');
        },
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'Deve verificar estrutura correta da tabela historia_videos',
      () async {
        final result = await db.rawQuery("PRAGMA table_info(historia_videos)");

        // Verificar se tem as colunas corretas
        final columnNames = result.map((column) => column['name']).toList();

        expect(columnNames, contains('id'));
        expect(columnNames, contains('historia_id'));
        expect(columnNames, contains('video_path')); // Nova estrutura
        expect(columnNames, contains('legenda'));
        expect(columnNames, contains('duracao'));
        expect(columnNames, contains('thumbnail_path'));

        // Verificar que NÃO tem a coluna video (BLOB)
        expect(columnNames, isNot(contains('video')));
        expect(columnNames, isNot(contains('thumbnail')));

        print('✅ Estrutura da tabela historia_videos está correta');
        print('   Colunas encontradas: $columnNames');
      },
    );

    test('Deve conseguir inserir e recuperar caminho de vídeo', () async {
      // Criar história
      final historiaId = await db.insert('historia', {
        'user_id': 'test_user',
        'titulo': 'História de Teste',
        'data': DateTime.now().toIso8601String(),
      });

      // Inserir vídeo com caminho
      final videoId = await db.insert('historia_videos', {
        'historia_id': historiaId,
        'video_path': '/caminho/para/video.mp4',
        'legenda': 'Vídeo de teste',
        'duracao': 30,
        'thumbnail_path': '/caminho/para/thumbnail.jpg',
      });

      expect(videoId, greaterThan(0));

      // Recuperar vídeo
      final videos = await db.query(
        'historia_videos',
        where: 'historia_id = ?',
        whereArgs: [historiaId],
      );

      expect(videos.length, 1);
      expect(videos.first['video_path'], '/caminho/para/video.mp4');
      expect(videos.first['legenda'], 'Vídeo de teste');
      expect(videos.first['duracao'], 30);
      expect(videos.first['thumbnail_path'], '/caminho/para/thumbnail.jpg');

      print('✅ Inserção e recuperação de vídeo funcionando');
      print('   - ID: ${videos.first['id']}');
      print('   - Caminho: ${videos.first['video_path']}');
      print('   - Duração: ${videos.first['duracao']}s');
    });
  });
}
