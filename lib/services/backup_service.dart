import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import '../helpers/video_file_helper.dart';
import '../db/database_helper.dart';

/// Serviço simplificado de backup - apenas arquivo ZIP local
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

      // Criar diretório temporário para o backup
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
        throw Exception('Banco de dados não encontrado.');
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

      // 3. Criar arquivo de metadados
      onProgress?.call('Criando metadados...');
      final timestamp = DateTime.now().toIso8601String();
      final metadataFile = File(path.join(backupDir.path, 'backup_info.txt'));
      await metadataFile.writeAsString('''
DayApp Backup
Data: $timestamp
Banco de dados: ${dbFile.lengthSync()} bytes
Vídeos: ${videoFiles.length} arquivo(s)
Versão: 1.0.0
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

      // Adicionar vídeos com estrutura videos/
      final videosBackupDir = Directory(path.join(backupDir.path, 'videos'));
      if (await videosBackupDir.exists()) {
        final videoFiles = videosBackupDir
            .listSync()
            .whereType<File>()
            .toList();
        debugPrint('Adicionando ${videoFiles.length} vídeos ao ZIP');

        for (final videoFile in videoFiles) {
          final videoData = await videoFile.readAsBytes();
          final videoName = path.basename(videoFile.path);
          archive.addFile(
            ArchiveFile('videos/$videoName', videoData.length, videoData),
          );
          debugPrint('Vídeo adicionado ao ZIP: $videoName');
        }
      }

      // Codificar e salvar ZIP
      final zipData = ZipEncoder().encode(archive);
      await File(zipPath).writeAsBytes(zipData!);

      // Limpar diretório temporário
      await backupDir.delete(recursive: true);

      onProgress?.call('Backup criado com sucesso!');
      debugPrint('[BACKUP] Arquivo ZIP criado: $zipPath');
      debugPrint(
        '[BACKUP] Tamanho do ZIP: ${File(zipPath).lengthSync()} bytes',
      );
      return zipPath;
    } catch (e) {
      debugPrint('[BACKUP] Erro ao criar arquivo de backup: $e');
      rethrow;
    }
  }

  /// Compartilha o arquivo de backup (para salvar no OneDrive, Google Drive, etc)
  Future<void> shareBackupFile({void Function(String)? onProgress}) async {
    try {
      final zipPath = await createBackupZipFile(onProgress: onProgress);
      final zipFile = File(zipPath);

      if (!await zipFile.exists()) {
        throw Exception('Arquivo de backup não encontrado.');
      }

      // Compartilhar arquivo
      // ignore: deprecated_member_use
      final result = await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Backup DayApp',
        text: 'Backup completo do DayApp com banco de dados e vídeos',
      );

      debugPrint('[BACKUP] Compartilhamento: ${result.status}');
    } catch (e) {
      debugPrint('[BACKUP] Erro ao compartilhar backup: $e');
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

      debugPrint(
        '[BACKUP_RESTORE] ZIP contém ${archive.length} arquivos/pastas',
      );
      onProgress?.call('ZIP contém ${archive.length} arquivos...');

      for (final file in archive) {
        debugPrint(
          '[BACKUP_RESTORE] Extraindo: ${file.name} (isFile: ${file.isFile})',
        );
        final filename = path.join(extractDir.path, file.name);
        if (file.isFile) {
          final outFile = File(filename);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          debugPrint('[BACKUP_RESTORE] Arquivo extraído: $filename');
        } else {
          await Directory(filename).create(recursive: true);
          debugPrint('[BACKUP_RESTORE] Diretório criado: $filename');
        }
      }

      // Listar conteúdo extraído para debug
      debugPrint('[BACKUP_RESTORE] Conteúdo completo extraído:');
      for (final entity in extractDir.listSync(recursive: true)) {
        debugPrint('[BACKUP_RESTORE]   - ${entity.path}');
      }

      // Função auxiliar para encontrar arquivo recursivamente
      File? findFile(Directory dir, String fileName) {
        for (final entity in dir.listSync(recursive: true)) {
          if (entity is File && path.basename(entity.path) == fileName) {
            debugPrint('Arquivo encontrado: ${entity.path}');
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
      debugPrint('[BACKUP_RESTORE] Procurando dayapp.db em ${extractDir.path}');
      final restoredDb = findFile(extractDir, 'dayapp.db');

      if (restoredDb != null && await restoredDb.exists()) {
        debugPrint(
          '[BACKUP_RESTORE] Banco encontrado! Copiando de ${restoredDb.path} para ${currentDb.path}',
        );

        // Fechar todas as conexões com o banco antes de deletar
        if (await currentDb.exists()) {
          debugPrint('[BACKUP_RESTORE] Fechando conexões com o banco...');
          try {
            await DatabaseHelper().resetDatabase();
            // Aguardar um pouco para garantir que o arquivo foi liberado
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (e) {
            debugPrint(
              '[BACKUP_RESTORE] Erro ao fechar banco (pode ser normal): $e',
            );
          }

          debugPrint('[BACKUP_RESTORE] Deletando banco existente...');
          await currentDb.delete();
        }

        await restoredDb.copy(currentDb.path);
        debugPrint('[BACKUP_RESTORE] Banco copiado com sucesso!');
      } else {
        // Listar todos os arquivos para debug
        debugPrint('[BACKUP_RESTORE] ERRO: Banco de dados NÃO encontrado!');
        debugPrint('[BACKUP_RESTORE] Conteúdo do diretório extraído:');
        for (final entity in extractDir.listSync(recursive: true)) {
          debugPrint('[BACKUP_RESTORE]   - ${entity.path}');
        }
        throw Exception(
          'Banco de dados não encontrado no arquivo de backup. '
          'Arquivos extraídos: ${extractDir.listSync(recursive: true).length}',
        );
      }

      // 3. Restaurar vídeos
      onProgress?.call('Restaurando vídeos...');

      // Procurar pasta de vídeos recursivamente
      Directory? videosRestoreDir;
      for (final entity in extractDir.listSync(recursive: true)) {
        if (entity is Directory && path.basename(entity.path) == 'videos') {
          videosRestoreDir = entity;
          debugPrint('Pasta de vídeos encontrada: ${entity.path}');
          break;
        }
      }

      if (videosRestoreDir != null && await videosRestoreDir.exists()) {
        // Limpar vídeos atuais
        final videosDir = await VideoFileHelper.getVideosDirectory();
        final currentVideos = videosDir.listSync();
        for (final file in currentVideos) {
          if (file is File) {
            await file.delete();
          }
        }

        // Copiar vídeos restaurados
        final restoredVideos = videosRestoreDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.mp4'))
            .toList();

        debugPrint(
          'Encontrados ${restoredVideos.length} vídeos para restaurar',
        );

        for (int i = 0; i < restoredVideos.length; i++) {
          final videoFile = restoredVideos[i];
          final videoFileName = path.basename(videoFile.path);
          onProgress?.call(
            'Restaurando vídeo ${i + 1}/${restoredVideos.length}...',
          );

          final destFile = File(path.join(videosDir.path, videoFileName));
          await videoFile.copy(destFile.path);
          debugPrint('Vídeo copiado: $videoFileName');
        }
      } else {
        debugPrint('Nenhuma pasta de vídeos encontrada no backup');
      }

      // Limpar diretório temporário
      await extractDir.delete(recursive: true);

      onProgress?.call('Restauração concluída com sucesso!');
      debugPrint('Restauração do ZIP concluída!');
    } catch (e) {
      debugPrint('Erro ao restaurar do arquivo ZIP: $e');
      rethrow;
    }
  }
}
