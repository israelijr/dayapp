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
import '../l10n/generated/app_localizations.dart';

/// ServiÃ§o simplificado de backup - apenas arquivo ZIP local
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Cria um arquivo ZIP com backup completo e permite compartilhar
  /// (para OneDrive, Google Drive, etc)
  Future<String> createBackupZipFile({
    void Function(String)? onProgress,
    AppLocalizations? l10n,
  }) async {
    try {
      onProgress?.call(
        l10n?.backupProgressCreating ?? 'Criando arquivo de backup...',
      );

      // Criar diretÃ³rio temporÃ¡rio para o backup
      final tempDir = await getTemporaryDirectory();
      final backupDir = Directory(path.join(tempDir.path, 'backup_export'));
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
      await backupDir.create(recursive: true);

      // 1. Copiar banco de dados
      onProgress?.call(
        l10n?.backupProgressCopyingDb ?? 'Copiando banco de dados...',
      );
      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, 'dayapp.db'));

      if (!await dbFile.exists()) {
        throw Exception(
          l10n?.errorBackupDbNotFound ?? 'Banco de dados não encontrado.',
        );
      }

      // Marcar histórias como já salvas em backup antes de copiar o arquivo
      try {
        final db = await DatabaseHelper().database;
        // Marca somente histórias não excluídas
        await db.update('historia', {
          'backed_up': 1,
        }, where: 'excluido IS NULL');
      } catch (e) {
        // Não quebrar o fluxo de backup se a marcação falhar
      }

      final dbBackupFile = File(path.join(backupDir.path, 'dayapp.db'));
      await dbFile.copy(dbBackupFile.path);

      // 2. Copiar vídeos
      onProgress?.call(
        l10n?.backupProgressCopyingVideos ?? 'Copiando vídeos...',
      );
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
          onProgress?.call(
            l10n?.backupProgressCopyingVideo(i + 1, videoFiles.length) ??
                'Copiando vídeo ${i + 1}/${videoFiles.length}...',
          );

          final videoBackupFile = File(
            path.join(videosBackupDir.path, videoFileName),
          );
          await videoFile.copy(videoBackupFile.path);
        }
      }

      // 3. Copiar fotos
      onProgress?.call(
        l10n?.backupProgressCopyingPhotos ?? 'Copiando fotos...',
      );
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
          onProgress?.call(
            l10n?.backupProgressCopyingPhoto(i + 1, photoFiles.length) ??
                'Copiando foto ${i + 1}/${photoFiles.length}...',
          );

          final photoBackupFile = File(
            path.join(photosBackupDir.path, photoFileName),
          );
          await photoFile.copy(photoBackupFile.path);
        }
      }

      // 4. Copiar áudios
      onProgress?.call(
        l10n?.backupProgressCopyingAudios ?? 'Copiando áudios...',
      );
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
          onProgress?.call(
            l10n?.backupProgressCopyingAudio(i + 1, audioFiles.length) ??
                'Copiando áudio ${i + 1}/${audioFiles.length}...',
          );

          final audioBackupFile = File(
            path.join(audiosBackupDir.path, audioFileName),
          );
          await audioFile.copy(audioBackupFile.path);
        }
      }

      // 5. Criar arquivo de metadados
      onProgress?.call(
        l10n?.backupProgressCreatingMetadata ?? 'Criando metadados...',
      );
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
      onProgress?.call(
        l10n?.backupProgressCompressing ?? 'Comprimindo arquivos...',
      );
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

      onProgress?.call(
        l10n?.backupProgressSuccess ?? 'Backup criado com sucesso!',
      );
      return zipPath;
    } catch (e) {
      rethrow;
    }
  }

  /// Compartilha o arquivo de backup (para salvar no OneDrive, Google Drive, etc)
  Future<void> shareBackupFile({
    void Function(String)? onProgress,
    AppLocalizations? l10n,
  }) async {
    try {
      final zipPath = await createBackupZipFile(
        onProgress: onProgress,
        l10n: l10n,
      );
      final zipFile = File(zipPath);

      if (!await zipFile.exists()) {
        throw Exception(
          l10n?.errorBackupFileNotFound ?? 'Arquivo de backup não encontrado.',
        );
      }

      // Compartilhar arquivo
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Backup DayApp',
        text:
            l10n?.backupShareText ??
            'Backup completo do DayApp com banco de dados e vídeos',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Restaura backup de um arquivo ZIP
  Future<void> restoreFromZipFile(
    String zipFilePath, {
    void Function(String)? onProgress,
    AppLocalizations? l10n,
  }) async {
    try {
      onProgress?.call(
        l10n?.restoreProgressExtracting ?? 'Extraindo arquivo de backup...',
      );

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

      onProgress?.call(
        l10n?.restoreProgressZipContains(archive.length) ??
            'ZIP contém ${archive.length} arquivos...',
      );

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
      onProgress?.call(
        l10n?.restoreProgressBackingUpCurrent ??
            'Fazendo backup do banco atual...',
      );
      final dbPath = await getDatabasesPath();
      final currentDb = File(path.join(dbPath, 'dayapp.db'));

      if (await currentDb.exists()) {
        final backupCurrent = File(path.join(dbPath, 'dayapp_backup_local.db'));
        await currentDb.copy(backupCurrent.path);
      }

      // 2. Restaurar banco de dados
      onProgress?.call(
        l10n?.restoreProgressRestoringDb ?? 'Restaurando banco de dados...',
      );

      // Procurar o arquivo do banco de dados recursivamente
      final restoredDb = findFile(extractDir, 'dayapp.db');

      if (restoredDb != null && await restoredDb.exists()) {
        // Fechar todas as conexões com o banco antes de substituir
        onProgress?.call(
          l10n?.restoreProgressClosingDb ?? 'Fechando conexões do banco...',
        );
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
        onProgress?.call(
          l10n?.restoreProgressCopyingRestoredDb ??
              'Copiando banco de dados restaurado...',
        );
        await restoredDb.copy(currentDb.path);
        // Após copiar o banco restaurado, garantir compatibilidade com a nova
        // coluna `backed_up` e marcar todas as histórias do backup como já salvas.
        try {
          final restoredDbPath = path.join(dbPath, 'dayapp.db');
          final tmpDb = await openDatabase(restoredDbPath);
          try {
            final tableInfo = await tmpDb.rawQuery(
              'PRAGMA table_info(historia)',
            );
            final hasBackedUp = tableInfo.any((c) => c['name'] == 'backed_up');
            if (!hasBackedUp) {
              try {
                await tmpDb.execute(
                  'ALTER TABLE historia ADD COLUMN backed_up INTEGER DEFAULT 0;',
                );
              } catch (_) {
                // ignore
              }
            }
            // Compatibilidade: backups anteriores ao v14 não possuem as colunas
            // humor e energia — adicioná-las com os valores padrão.
            final hasHumor = tableInfo.any((c) => c['name'] == 'humor');
            if (!hasHumor) {
              try {
                await tmpDb.execute(
                  'ALTER TABLE historia ADD COLUMN humor INTEGER DEFAULT 3;',
                );
                await tmpDb.execute(
                  'UPDATE historia SET humor = 3 WHERE humor IS NULL;',
                );
              } catch (_) {
                // ignore
              }
            }
            final hasEnergia = tableInfo.any((c) => c['name'] == 'energia');
            if (!hasEnergia) {
              try {
                await tmpDb.execute(
                  'ALTER TABLE historia ADD COLUMN energia INTEGER DEFAULT 2;',
                );
                await tmpDb.execute(
                  'UPDATE historia SET energia = 2 WHERE energia IS NULL;',
                );
              } catch (_) {
                // ignore
              }
            }
            // Marcar todas as histórias deste banco restaurado como já salvas
            await tmpDb.update('historia', {'backed_up': 1});

            // --- Compatibilidade v15: tabelas de tags ---
            // Garante existência das tabelas independente da versão do backup.
            try {
              await tmpDb.execute('''
                CREATE TABLE IF NOT EXISTS tags (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  user_id TEXT NOT NULL,
                  nome TEXT NOT NULL,
                  slug TEXT NOT NULL,
                  UNIQUE(user_id, slug),
                  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                );
              ''');
              await tmpDb.execute('''
                CREATE TABLE IF NOT EXISTS historia_tags (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  historia_id INTEGER NOT NULL,
                  tag_id INTEGER NOT NULL,
                  UNIQUE(historia_id, tag_id),
                  FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE,
                  FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
                );
              ''');
              await tmpDb.execute(
                'CREATE INDEX IF NOT EXISTS idx_tags_user_slug ON tags(user_id, slug);',
              );
              await tmpDb.execute(
                'CREATE INDEX IF NOT EXISTS idx_historia_tags_historia ON historia_tags(historia_id);',
              );
              await tmpDb.execute(
                'CREATE INDEX IF NOT EXISTS idx_historia_tags_tag ON historia_tags(tag_id);',
              );
            } catch (_) {
              // Tabelas/índices já existem; ignorar
            }

            // Verificar a versão gravada no backup para aplicar migrações
            // pendentes antes de o DatabaseHelper reabrir o banco.
            final List<Map<String, dynamic>> versionRows = await tmpDb.rawQuery(
              'PRAGMA user_version',
            );
            final int backupVersion =
                (versionRows.firstOrNull?['user_version'] as int?) ?? 0;

            // Compatibilidade v15: popular tabelas de tags a partir do campo
            // texto legado `historia.tag` (backups anteriores à v15).
            if (backupVersion < 15) {
              try {
                await DatabaseHelper.migrateTagsFromLegacyField(tmpDb);
              } catch (_) {
                // Migração de tags não crítica; continuar normalmente
              }
            }

            // Compatibilidade v16: nova escala de humor 1–5 (antes era 1–4).
            // O emoji "Muito difícil" foi adicionado na posição 1, deslocando
            // todos os valores antigos +1 (Difícil=1→2, Neutro=2→3, etc.).
            if (backupVersion < 16) {
              try {
                await tmpDb.execute(
                  'UPDATE historia SET humor = humor + 1 WHERE humor BETWEEN 1 AND 4;',
                );
                await tmpDb.execute(
                  'UPDATE historia SET humor = 3 WHERE humor IS NULL;',
                );
                // Atualizar user_version para evitar dupla migração quando
                // DatabaseHelper reabrir o banco com version: 16.
                await tmpDb.execute('PRAGMA user_version = 16;');
              } catch (_) {
                // Migração não crítica; ignorar
              }
            }
          } finally {
            await tmpDb.close();
          }
        } catch (e) {
          // Não falhar a restauração se a marcação não funcionar
        }
      } else {
        throw Exception(
          l10n?.errorBackupDbNotFoundInFile(
                extractDir.listSync(recursive: true).length,
              ) ??
              'Banco de dados não encontrado no arquivo de backup. '
                  'Arquivos extraídos: ${extractDir.listSync(recursive: true).length}',
        );
      }

      // 3. Restaurar vÃ­deos
      onProgress?.call(
        l10n?.restoreProgressRestoringVideos ?? 'Restaurando vídeos...',
      );

      // Procurar pasta de vídeos recursivamente
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
            l10n?.restoreProgressRestoringVideo(i + 1, restoredVideos.length) ??
                'Restaurando vídeo ${i + 1}/${restoredVideos.length}...',
          );

          final destFile = File(path.join(videosDir.path, videoFileName));
          await videoFile.copy(destFile.path);
        }
      }

      // 4. Restaurar fotos
      onProgress?.call(
        l10n?.restoreProgressRestoringPhotos ?? 'Restaurando fotos...',
      );

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
            l10n?.restoreProgressRestoringPhoto(i + 1, restoredPhotos.length) ??
                'Restaurando foto ${i + 1}/${restoredPhotos.length}...',
          );

          final destFile = File(path.join(photosDir.path, photoFileName));
          await photoFile.copy(destFile.path);
        }
      }

      // 5. Restaurar áudios
      onProgress?.call(
        l10n?.restoreProgressRestoringAudios ?? 'Restaurando áudios...',
      );

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
            l10n?.restoreProgressRestoringAudio(i + 1, restoredAudios.length) ??
                'Restaurando áudio ${i + 1}/${restoredAudios.length}...',
          );

          final destFile = File(path.join(audiosDir.path, audioFileName));
          await audioFile.copy(destFile.path);
        }
      }

      // Limpar diretório temporário
      await extractDir.delete(recursive: true);

      // Reinicializar conexão com o banco de dados restaurado
      onProgress?.call(
        l10n?.restoreProgressReinitializingDb ??
            'Reinicializando banco de dados...',
      );

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
        l10n?.restoreProgressDbStats(
              activeCount.first['cnt'] as int,
              deletedCount.first['cnt'] as int,
            ) ??
            'Banco restaurado: ${activeCount.first['cnt']} ativas, '
                '${deletedCount.first['cnt']} na lixeira.',
      );

      onProgress?.call(
        l10n?.restoreSuccess ?? 'Restauração concluída com sucesso!',
      );
    } catch (e) {
      rethrow;
    }
  }
}
