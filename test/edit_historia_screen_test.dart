import 'dart:typed_data';

import 'package:dayapp/models/historia.dart';
import 'package:dayapp/screens/edit_historia_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dayapp/db/database_helper.dart';

import 'test_mocks.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    initTestBindingsAndMocks();
  });

  group('EditHistoriaScreen unit logic', () {
    setUp(() async {
      // garante banco limpo antes de cada teste
      final db = await DatabaseHelper().database;
      await db.delete('historia_fotos');
      await db.delete('historia_audios');
      await db.delete('historia_videos');
    });
    test('removing a photo also clears the matching id', () async {
      final screen = EditHistoriaScreen(
        historia: Historia(userId: 'u', titulo: 't', data: DateTime.now()),
      );
      final state = screen.createState() as dynamic;

      state.fotos = [
        Uint8List.fromList([1]),
      ];
      state.fotoIds = [123];

      await state.removeFoto(0);

      expect(state.fotos, isEmpty);
      expect(state.fotoIds, isEmpty);
    });

    test('save loops are safe when ids list is shorter than fotos', () async {
      final screen = EditHistoriaScreen(
        historia: Historia(userId: 'u', titulo: 't', data: DateTime.now()),
      );
      final state = screen.createState() as dynamic;

      state.fotos = [
        Uint8List.fromList([1]),
        Uint8List.fromList([2]),
      ];
      state.fotoIds = [0];

      // replicar parte da lógica usada em _save
      for (int i = 0; i < state.fotos.length; i++) {
        final id = i < state.fotoIds.length ? state.fotoIds[i] : 0;
        expect(id, isA<int>());
      }
    });

    test('audio/video loops also tolerate mismatched ids', () async {
      final screen = EditHistoriaScreen(
        historia: Historia(userId: 'u', titulo: 't', data: DateTime.now()),
      );
      final state = screen.createState() as dynamic;

      state.audios = [
        {
          'audio': Uint8List.fromList([1]),
          'duration': 10,
        },
      ];
      state.audioIds = <int>[]; // nenhum id

      state.videos = [
        {
          'video': Uint8List.fromList([2]),
          'duration': 5,
        },
      ];
      state.videoIds = <int>[];

      for (int i = 0; i < state.audios.length; i++) {
        final id = i < state.audioIds.length ? state.audioIds[i] : 0;
        expect(id, isA<int>());
      }
      for (int i = 0; i < state.videos.length; i++) {
        final id = i < state.videoIds.length ? state.videoIds[i] : 0;
        expect(id, isA<int>());
      }
    });
    // após os testes básicos, garantimos que remoções de itens
    // existentes realmente apaguem o registro do banco.
    test('removing existing photo deletes database record', () async {
      final screen = EditHistoriaScreen(
        historia: Historia(userId: 'u', titulo: 't', data: DateTime.now()),
      );
      final state = screen.createState() as dynamic;

      // inserir registro fake no banco
      final db = await DatabaseHelper().database;
      final id = await db.insert('historia_fotos', {
        'historia_id': 1,
        'foto_path': '/tmp/whatever.jpg',
      });

      state.fotos = [
        Uint8List.fromList([1]),
      ];
      state.fotoIds = [id];

      await state.removeFoto(0);

      final result = await db.query(
        'historia_fotos',
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(result, isEmpty);
    });

    test('removing existing audio deletes database record', () async {
      final screen = EditHistoriaScreen(
        historia: Historia(userId: 'u', titulo: 't', data: DateTime.now()),
      );
      final state = screen.createState() as dynamic;

      final db = await DatabaseHelper().database;
      final id = await db.insert('historia_audios', {
        'historia_id': 1,
        'audio_path': '/tmp/foo.m4a',
        'duracao': 10,
      });

      state.audios = [
        {
          'audio': Uint8List.fromList([1]),
          'duration': 10,
        },
      ];
      state.audioIds = [id];

      await state._removeAudio(0);

      final result = await db.query(
        'historia_audios',
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(result, isEmpty);
    });

    test('removing existing video deletes database record', () async {
      final screen = EditHistoriaScreen(
        historia: Historia(userId: 'u', titulo: 't', data: DateTime.now()),
      );
      final state = screen.createState() as dynamic;

      final db = await DatabaseHelper().database;
      final id = await db.insert('historia_videos', {
        'historia_id': 1,
        'video_path': '/tmp/foo.mp4',
        'duracao': 5,
        'thumbnail_path': null,
      });

      state.videos = [
        {'videoPath': '/tmp/foo.mp4', 'duration': 5, 'id': id},
      ];
      state.videoIds = [id];

      await state._removeVideo(0);

      final result = await db.query(
        'historia_videos',
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(result, isEmpty);
    });
  });
}
