import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../helpers/audio_file_helper.dart';
import '../helpers/photo_file_helper.dart';
import '../helpers/video_file_helper.dart';

/// ServiÃ§o simplificado de backup - apenas arquivo ZIP local
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Cria um arquivo ZIP com backup completo e permite compartilhar
  /// (para OneDrive, Google Drive, etc)
  Future<String> createBackupZipFile({
    void Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('Criando arquivo de backup...');

      // Criar diretÃ³rio temporÃ¡rio para o backup
      final tempDir = await getTemporaryDirectory();
      final backupDir = Directory(path.join(tempDir.path, 'backup_export'));
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
      await backupDir.create(recursive: true);

      // 1. Copiar banco de dados
      onProgress?.call('Copiando banco de dados...');
      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, 'dayapp.db'));

      if (!await dbFile.exists()) {
        throw Exception('Banco de dados nÃ£o encontrado.');
      }

      final dbBackupFile = File(path.join(backupDir.path, 'dayapp.db'));
      await dbFile.copy(dbBackupFile.path);

      // 2. Copiar vídeos
      onProgress?.call('Copiando vídeos...');
      final videosDir = await VideoFileHelper.getVideosDirectory();
      final videoFiles = videosDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.mp4'))
          .toList();

      if (videoFiles.isNotEmpty) {
        final videosBackupDir = Directory(path.join(backupDir.path, 'videos'));
        await videosBackupDir.create();

        for (int i = 0; i < videoFiles.length; i++) {
          final videoFile = videoFiles[i];
          final videoFileName = path.basename(videoFile.path);
          onProgress?.call('Copiando vídeo ${i + 1}/${videoFiles.length}...');

          final videoBackupFile = File(
            path.join(videosBackupDir.path, videoFileName),
          );
          await videoFile.copy(videoBackupFile.path);
        }
      }

      // 3. Copiar fotos
      onProgress?.call('Copiando fotos...');
      final photosDir = await PhotoFileHelper.getPhotosDirectory();
      final photoFiles = photosDir
          .listSync()
          .whereType<File>()
          .where(
            (file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'),
          )
          .toList();

      if (photoFiles.isNotEmpty) {
        final photosBackupDir = Directory(path.join(backupDir.path, 'photos'));
        await photosBackupDir.create();

        for (int i = 0; i < photoFiles.length; i++) {
          final photoFile = photoFiles[i];
          final photoFileName = path.basename(photoFile.path);
          onProgress?.call('Copiando foto ${i + 1}/${photoFiles.length}...');

          final photoBackupFile = File(
            path.join(photosBackupDir.path, photoFileName),
          );
          await photoFile.copy(photoBackupFile.path);
        }
      }

      // 4. Copiar áudios
      onProgress?.call('Copiando áudios...');
      final audiosDir = await AudioFileHelper.getAudiosDirectory();
      final audioFiles = audiosDir
          .listSync()
          .whereType<File>()
          .where(
            (file) => file.path.endsWith('.m4a') || file.path.endsWith('.mp3'),
          )
          .toList();

      if (audioFiles.isNotEmpty) {
        final audiosBackupDir = Directory(path.join(backupDir.path, 'audios'));
        await audiosBackupDir.create();

        for (int i = 0; i < audioFiles.length; i++) {
          final audioFile = audioFiles[i];
          final audioFileName = path.basename(audioFile.path);
          onProgress?.call('Copiando áudio ${i + 1}/${audioFiles.length}...');

          final audioBackupFile = File(
            path.join(audiosBackupDir.path, audioFileName),
          );
          await audioFile.copy(audioBackupFile.path);
        }
      }

      // 5. Criar arquivo de metadados
      onProgress?.call('Criando metadados...');
      final timestamp = DateTime.now().toIso8601String();
      final metadataFile = File(path.join(backupDir.path, 'backup_info.txt'));
      await metadataFile.writeAsString('''
DayApp Backup
Data: $timestamp
Banco de dados: ${dbFile.lengthSync()} bytes
Vídeos: ${videoFiles.length} arquivo(s)
Fotos: ${photoFiles.length} arquivo(s)
Áudios: ${audioFiles.length} arquivo(s)
Versão: 2.0.0
''');

      // 6. Comprimir tudo em ZIP
      onProgress?.call('Comprimindo arquivos...');
      final timestamp2 = DateTime.now().millisecondsSinceEpoch;
      final zipPath = path.join(tempDir.path, 'dayapp_backup_$timestamp2.zip');

      // Criar arquivo usando Archive em vez de ZipFileEncoder para melhor controle
      final archive = Archive();

      // Adicionar banco de dados na raiz do ZIP
      final dbFileData = await File(
        path.join(backupDir.path, 'dayapp.db'),
      ).readAsBytes();
      archive.addFile(ArchiveFile('dayapp.db', dbFileData.length, dbFileData));

      // Adicionar metadados na raiz do ZIP
      final metadataData = await File(
        path.join(backupDir.path, 'backup_info.txt'),
      ).readAsBytes();
      archive.addFile(
        ArchiveFile('backup_info.txt', metadataData.length, metadataData),
      );

      // Adicionar vídeos com estrutura videos/
      final videosBackupDir = Directory(path.join(backupDir.path, 'videos'));
      if (await videosBackupDir.exists()) {
        final backupVideoFiles = videosBackupDir
            .listSync()
            .whereType<File>()
            .toList();
        for (final videoFile in backupVideoFiles) {
          final videoData = await videoFile.readAsBytes();
          final videoName = path.basename(videoFile.path);
          archive.addFile(
            ArchiveFile('videos/$videoName', videoData.length, videoData),
          );
        }
      }

      // Adicionar fotos com estrutura photos/
      final photosBackupDir = Directory(path.join(backupDir.path, 'photos'));
      if (await photosBackupDir.exists()) {
        final backupPhotoFiles = photosBackupDir
            .listSync()
            .whereType<File>()
            .toList();
        for (final photoFile in backupPhotoFiles) {
          final photoData = await photoFile.readAsBytes();
          final photoName = path.basename(photoFile.path);
          archive.addFile(
            ArchiveFile('photos/$photoName', photoData.length, photoData),
          );
        }
      }

      // Adicionar áudios com estrutura audios/
      final audiosBackupDir = Directory(path.join(backupDir.path, 'audios'));
      if (await audiosBackupDir.exists()) {
        final backupAudioFiles = audiosBackupDir
            .listSync()
            .whereType<File>()
            .toList();
        for (final audioFile in backupAudioFiles) {
          final audioData = await audioFile.readAsBytes();
          final audioName = path.basename(audioFile.path);
          archive.addFile(
            ArchiveFile('audios/$audioName', audioData.length, audioData),
          );
        }
      }

      // Codificar e salvar ZIP
      final zipData = ZipEncoder().encode(archive);
      await File(zipPath).writeAsBytes(zipData!);

      // Limpar diretÃ³rio temporÃ¡rio
      await backupDir.delete(recursive: true);

      onProgress?.call('Backup criado com sucesso!');
      return zipPath;
    } catch (e) {
      rethrow;
    }
  }

  /// Compartilha o arquivo de backup (para salvar no OneDrive, Google Drive, etc)
  Future<void> shareBackupFile({void Function(String)? onProgress}) async {
    try {
      final zipPath = await createBackupZipFile(onProgress: onProgress);
      final zipFile = File(zipPath);

      if (!await zipFile.exists()) {
        throw Exception('Arquivo de backup nÃ£o encontrado.');
      }

      // Compartilhar arquivo
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Backup DayApp',
        text: 'Backup completo do DayApp com banco de dados e vídeos',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Restaura backup de um arquivo ZIP
  Future<void> restoreFromZipFile(
    String zipFilePath, {
    void Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('Extraindo arquivo de backup...');

      // Criar diretório temporário
      final tempDir = await getTemporaryDirectory();

      final extractDir = Directory(path.join(tempDir.path, 'backup_restore'));
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);

      // Extrair ZIP
      final zipFile = File(zipFilePath);
      final bytes = await zipFile.readAsBytes();

      final archive = ZipDecoder().decodeBytes(bytes);

      onProgress?.call('ZIP contém ${archive.length} arquivos...');

      for (final file in archive) {
        final filename = path.join(extractDir.path, file.name);
        if (file.isFile) {
          final outFile = File(filename);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filename).create(recursive: true);
        }
      }

      // Função auxiliar para encontrar arquivo recursivamente
      File? findFile(Directory dir, String fileName) {
        for (final entity in dir.listSync(recursive: true)) {
          if (entity is File && path.basename(entity.path) == fileName) {
            return entity;
          }
        }
        return null;
      }

      // 1. Fazer backup do banco atual
      onProgress?.call('Fazendo backup do banco atual...');
      final dbPath = await getDatabasesPath();
      final currentDb = File(path.join(dbPath, 'dayapp.db'));

      if (await currentDb.exists()) {
        final backupCurrent = File(path.join(dbPath, 'dayapp_backup_local.db'));
        await currentDb.copy(backupCurrent.path);
      }

      // 2. Restaurar banco de dados
      onProgress?.call('Restaurando banco de dados...');

      // Procurar o arquivo do banco de dados recursivamente
      final restoredDb = findFile(extractDir, 'dayapp.db');

      if (restoredDb != null && await restoredDb.exists()) {
        // Fechar todas as conexões com o banco antes de substituir
        onProgress?.call('Fechando conexões do banco...');
        await DatabaseHelper().resetDatabase();

        // Usar deleteDatabase do sqflite para garantir que o arquivo é liberado
        final dbFullPath = path.join(dbPath, 'dayapp.db');
        await deleteDatabase(dbFullPath);

        // Remover arquivos WAL e SHM do SQLite (podem conter dados em cache)
        final walFile = File('$dbFullPath-wal');
        final shmFile = File('$dbFullPath-shm');
        if (await walFile.exists()) {
          await walFile.delete();
        }
        if (await shmFile.exists()) {
          await shmFile.delete();
        }

        // Aguardar para garantir que os arquivos foram liberados
        await Future.delayed(const Duration(milliseconds: 500));

        // Copiar banco restaurado
        onProgress?.call('Copiando banco de dados restaurado...');
        await restoredDb.copy(currentDb.path);
      } else {
        throw Exception(
          'Banco de dados não encontrado no arquivo de backup. '
          'Arquivos extraídos: ${extractDir.listSync(recursive: true).length}',
        );
      }

      // 3. Restaurar vÃ­deos
      onProgress?.call('Restaurando vÃ­deos...');

      // Procurar pasta de vÃ­deos recursivamente
      Directory? videosRestoreDir;
      for (final entity in extractDir.listSync(recursive: true)) {
        if (entity is Directory && path.basename(entity.path) == 'videos') {
          videosRestoreDir = entity;
          break;
        }
      }

      if (videosRestoreDir != null && await videosRestoreDir.exists()) {
        // Limpar vÃ­deos atuais
        final videosDir = await VideoFileHelper.getVideosDirectory();
        final currentVideos = videosDir.listSync();
        for (final file in currentVideos) {
          if (file is File) {
            await file.delete();
          }
        }

        // Copiar vÃ­deos restaurados
        final restoredVideos = videosRestoreDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.mp4'))
            .toList();

        for (int i = 0; i < restoredVideos.length; i++) {
          final videoFile = restoredVideos[i];
          final videoFileName = path.basename(videoFile.path);
          onProgress?.call(
            'Restaurando vÃ­deo ${i + 1}/${restoredVideos.length}...',
          );

          final destFile = File(path.join(videosDir.path, videoFileName));
          await videoFile.copy(destFile.path);
        }
      }

      // 4. Restaurar fotos
      onProgress?.call('Restaurando fotos...');

      Directory? photosRestoreDir;
      for (final entity in extractDir.listSync(recursive: true)) {
        if (entity is Directory && path.basename(entity.path) == 'photos') {
          photosRestoreDir = entity;
          break;
        }
      }

      if (photosRestoreDir != null && await photosRestoreDir.exists()) {
        // Limpar fotos atuais
        final photosDir = await PhotoFileHelper.getPhotosDirectory();
        final currentPhotos = photosDir.listSync();
        for (final file in currentPhotos) {
          if (file is File) {
            await file.delete();
          }
        }

        // Copiar fotos restauradas
        final restoredPhotos = photosRestoreDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
            .toList();

        for (int i = 0; i < restoredPhotos.length; i++) {
          final photoFile = restoredPhotos[i];
          final photoFileName = path.basename(photoFile.path);
          onProgress?.call(
            'Restaurando foto ${i + 1}/${restoredPhotos.length}...',
          );

          final destFile = File(path.join(photosDir.path, photoFileName));
          await photoFile.copy(destFile.path);
        }
      }

      // 5. Restaurar áudios
      onProgress?.call('Restaurando áudios...');

      Directory? audiosRestoreDir;
      for (final entity in extractDir.listSync(recursive: true)) {
        if (entity is Directory && path.basename(entity.path) == 'audios') {
          audiosRestoreDir = entity;
          break;
        }
      }

      if (audiosRestoreDir != null && await audiosRestoreDir.exists()) {
        // Limpar áudios atuais
        final audiosDir = await AudioFileHelper.getAudiosDirectory();
        final currentAudios = audiosDir.listSync();
        for (final file in currentAudios) {
          if (file is File) {
            await file.delete();
          }
        }

        // Copiar áudios restaurados
        final restoredAudios = audiosRestoreDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.m4a') || f.path.endsWith('.mp3'))
            .toList();

        for (int i = 0; i < restoredAudios.length; i++) {
          final audioFile = restoredAudios[i];
          final audioFileName = path.basename(audioFile.path);
          onProgress?.call(
            'Restaurando áudio ${i + 1}/${restoredAudios.length}...',
          );

          final destFile = File(path.join(audiosDir.path, audioFileName));
          await audioFile.copy(destFile.path);
        }
      }

      // Limpar diretório temporário
      await extractDir.delete(recursive: true);

      // Reinicializar conexão com o banco de dados restaurado
      onProgress?.call('Reinicializando banco de dados...');

      // Garantir que o singleton foi resetado
      await DatabaseHelper().resetDatabase();

      // Aguardar um pouco mais para garantir
      await Future.delayed(const Duration(milliseconds: 500));

      // Forçar reabertura do banco para carregar os dados restaurados
      final db = await DatabaseHelper().database;

      // Verificação: contar registros para confirmar que o banco foi carregado
      final deletedCount = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM historia WHERE excluido = 'sim'",
      );
      final activeCount = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM historia WHERE excluido IS NULL',
      );

      onProgress?.call(
        'Banco restaurado: ${activeCount.first['cnt']} ativas, '
        '${deletedCount.first['cnt']} na lixeira.',
      );

      onProgress?.call('Restauração concluída com sucesso!');
    } catch (e) {
      rethrow;
    }
  }
}
