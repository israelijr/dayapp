import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import '../lib/db/historia_video_helper.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

void main() {
  setUpAll(() {
    // Inicializar sqflite_ffi para testes
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Inicializar binding para testes
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Video Save Tests', () {
    late Database db;
    late HistoriaVideoHelper videoHelper;

    setUp(() async {
      // Criar banco de dados em memória para teste
      db = await openDatabase(
        ':memory:',
        version: 8,
        onCreate: (db, version) async {
          // Criar tabelas necessárias
          await db.execute('''
            CREATE TABLE historia (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL,
              titulo TEXT NOT NULL,
              descricao TEXT,
              tag TEXT,
              grupo TEXT,
              arquivado TEXT,
              excluido TEXT,
              data_exclusao TIMESTAMP,
              sentimento TEXT,
              emoticon TEXT,
              data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              data_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              foto_historia TEXT,
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

      videoHelper = HistoriaVideoHelper();
    });

    tearDown(() async {
      await db.close();
    });

    test('Deve salvar vídeo corretamente no banco', () async {
      // Primeiro, criar uma história
      final historiaId = await db.insert('historia', {
        'user_id': 'test_user',
        'titulo': 'História de Teste',
        'data': DateTime.now().toIso8601String(),
      });

      // Criar dados de vídeo fictícios
      final videoBytes = Uint8List.fromList([1, 2, 3, 4, 5]); // Dados fictícios

      // Tentar salvar o vídeo
      try {
        final videoId = await videoHelper.insertVideoFromBytes(
          historiaId: historiaId,
          videoBytes: videoBytes,
          duracao: 30,
        );

        expect(videoId, greaterThan(0));

        // Verificar se foi salvo no banco
        final videos = await db.query(
          'historia_videos',
          where: 'historia_id = ?',
          whereArgs: [historiaId],
        );

        expect(videos.length, 1);
        expect(videos.first['historia_id'], historiaId);
        expect(videos.first['duracao'], 30);
        expect(videos.first['video_path'], isNotNull);

        print('✅ Vídeo salvo com sucesso no banco de dados');
        print('   - ID do vídeo: $videoId');
        print('   - Caminho: ${videos.first['video_path']}');
        print('   - Duração: ${videos.first['duracao']} segundos');
      } catch (e) {
        print('❌ Erro ao salvar vídeo: $e');
        rethrow;
      }
    });

    test('Deve recuperar vídeos por história', () async {
      // Criar história
      final historiaId = await db.insert('historia', {
        'user_id': 'test_user',
        'titulo': 'História com Vídeos',
        'data': DateTime.now().toIso8601String(),
      });

      // Adicionar vídeos
      final video1Bytes = Uint8List.fromList([1, 2, 3]);
      final video2Bytes = Uint8List.fromList([4, 5, 6]);

      try {
        await videoHelper.insertVideoFromBytes(
          historiaId: historiaId,
          videoBytes: video1Bytes,
          duracao: 15,
        );

        await videoHelper.insertVideoFromBytes(
          historiaId: historiaId,
          videoBytes: video2Bytes,
          duracao: 25,
        );

        // Recuperar vídeos
        final videos = await videoHelper.getVideosByHistoria(historiaId);

        expect(videos.length, 2);
        expect(videos[0].historiaId, historiaId);
        expect(videos[1].historiaId, historiaId);

        print('✅ Vídeos recuperados com sucesso');
        print('   - Total de vídeos: ${videos.length}');
        print('   - Vídeo 1: ${videos[0].duracao}s');
        print('   - Vídeo 2: ${videos[1].duracao}s');
      } catch (e) {
        print('❌ Erro ao recuperar vídeos: $e');
        rethrow;
      }
    });
  });
}
