import 'dart:typed_data';

import 'package:dayapp/db/database_helper.dart';
import 'package:dayapp/db/historia_video_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'test_mocks.dart';

void main() {
  setUpAll(() {
    // Inicializar sqflite_ffi para testes
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Inicializar binding e mocks compartilhados
    initTestBindingsAndMocks();
  });

  group('Video Save Tests', () {
    late Database db;
    late HistoriaVideoHelper videoHelper;

    setUp(() async {
      // Usar o DatabaseHelper compartilhado para garantir que VideoHelper
      // e o teste operem sobre o mesmo banco
      db = await DatabaseHelper().database;

      // Limpar tabelas relevantes antes de cada teste
      await db.delete('historia_videos');
      await db.delete('historia');

      videoHelper = HistoriaVideoHelper();
    });

    test('Deve salvar vídeo corretamente no banco', () async {
      // Primeiro, criar uma história
      final historiaId = await db.insert('historia', {
        'user_id': 'test_user',
        'titulo': 'História de Teste',
        'data': DateTime.now().toIso8601String(),
      });

      // Criar dados de vídeo fictícios
      final videoBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

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
    });
  });
}
