import 'database_helper.dart';
import '../models/historia_video_v2.dart' as v2;
import '../helpers/video_file_helper.dart';
import 'package:flutter/foundation.dart';

class HistoriaVideoHelper {
  // Novo método que recebe bytes e retorna o caminho salvo
  Future<int> insertVideoFromBytes({
    required int historiaId,
    required Uint8List videoBytes,
    String? legenda,
    int? duracao,
  }) async {
    try {
      // 1. Salvar arquivo no sistema de arquivos
      debugPrint(
        'HistoriaVideoHelper: salvando vídeo no sistema de arquivos (${videoBytes.length} bytes)',
      );
      final videoPath = await VideoFileHelper.saveVideo(videoBytes, historiaId);
      debugPrint('HistoriaVideoHelper: vídeo salvo em: $videoPath');

      // 2. Inserir caminho no banco
      final db = await DatabaseHelper().database;
      final id = await db.insert('historia_videos', {
        'historia_id': historiaId,
        'video_path': videoPath,
        'legenda': legenda,
        'duracao': duracao,
        'thumbnail_path': null,
      });

      debugPrint('HistoriaVideoHelper: registro inserido no banco com ID: $id');
      return id;
    } catch (e) {
      debugPrint('HistoriaVideoHelper: erro ao inserir vídeo: $e');
      rethrow;
    }
  }

  Future<List<v2.HistoriaVideo>> getVideosByHistoria(int historiaId) async {
    try {
      final db = await DatabaseHelper().database;
      debugPrint(
        'HistoriaVideoHelper: buscando vídeos para historia_id: $historiaId',
      );

      final result = await db.query(
        'historia_videos',
        where: 'historia_id = ?',
        whereArgs: [historiaId],
      );

      debugPrint('HistoriaVideoHelper: encontrados ${result.length} vídeos');
      return result.map((map) => v2.HistoriaVideo.fromMap(map)).toList();
    } catch (e) {
      debugPrint('HistoriaVideoHelper: erro ao buscar vídeos: $e');
      rethrow;
    }
  }

  Future<int> deleteVideo(int id, String videoPath) async {
    try {
      // 1. Deletar arquivo do sistema de arquivos
      debugPrint('HistoriaVideoHelper: deletando arquivo: $videoPath');
      await VideoFileHelper.deleteVideo(videoPath);

      // 2. Deletar registro do banco
      final db = await DatabaseHelper().database;
      final result = await db.delete(
        'historia_videos',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('HistoriaVideoHelper: registro deletado do banco');

      return result;
    } catch (e) {
      debugPrint('HistoriaVideoHelper: erro ao deletar vídeo: $e');
      rethrow;
    }
  }

  Future<void> deleteVideosByHistoria(int historiaId) async {
    try {
      // 1. Buscar todos os vídeos da história
      final videos = await getVideosByHistoria(historiaId);

      // 2. Deletar cada arquivo
      for (final video in videos) {
        await VideoFileHelper.deleteVideo(video.videoPath);
        if (video.thumbnailPath != null) {
          await VideoFileHelper.deleteVideo(video.thumbnailPath!);
        }
      }

      // 3. Deletar registros do banco
      final db = await DatabaseHelper().database;
      await db.delete(
        'historia_videos',
        where: 'historia_id = ?',
        whereArgs: [historiaId],
      );
      debugPrint('HistoriaVideoHelper: ${videos.length} vídeos deletados');
    } catch (e) {
      debugPrint('HistoriaVideoHelper: erro ao deletar vídeos da história: $e');
      rethrow;
    }
  }
}
