import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import '../helpers/video_file_helper.dart';
import '../db/database_helper.dart';

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

      // 2. Copiar vÃ­deos
      onProgress?.call('Copiando vÃ­deos...');
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
          onProgress?.call('Copiando vÃ­deo ${i + 1}/${videoFiles.length}...');

          final videoBackupFile = File(
            path.join(videosBackupDir.path, videoFileName),
          );
          await videoFile.copy(videoBackupFile.path);
        }
      }

      // 3. Criar arquivo de metadados
      onProgress?.call('Criando metadados...');
      final timestamp = DateTime.now().toIso8601String();
      final metadataFile = File(path.join(backupDir.path, 'backup_info.txt'));
      await metadataFile.writeAsString('''
DayApp Backup
Data: $timestamp
Banco de dados: ${dbFile.lengthSync()} bytes
VÃ­deos: ${videoFiles.length} arquivo(s)
VersÃ£o: 1.0.0
''');

      // 4. Comprimir tudo em ZIP
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

      // Adicionar vÃ­deos com estrutura videos/
      final videosBackupDir = Directory(path.join(backupDir.path, 'videos'));
      if (await videosBackupDir.exists()) {
        final videoFiles = videosBackupDir
            .listSync()
            .whereType<File>()
            .toList();

        for (final videoFile in videoFiles) {
          final videoData = await videoFile.readAsBytes();
          final videoName = path.basename(videoFile.path);
          archive.addFile(
            ArchiveFile('videos/$videoName', videoData.length, videoData),
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

      // Criar diretÃ³rio temporÃ¡rio
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

      onProgress?.call('ZIP contÃ©m ${archive.length} arquivos...');

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
        // Fechar todas as conexÃµes com o banco antes de deletar
        if (await currentDb.exists()) {
          try {
            await DatabaseHelper().resetDatabase();
            // Aguardar um pouco para garantir que o arquivo foi liberado
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (e) {}

          await currentDb.delete();
        }

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
      } else {}

      // Limpar diretÃ³rio temporÃ¡rio
      await extractDir.delete(recursive: true);

      onProgress?.call('RestauraÃ§Ã£o concluÃ­da com sucesso!');
    } catch (e) {
      rethrow;
    }
  }
}
