import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import '../helpers/video_file_helper.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  // Lazily access Firebase singletons so the class can be instantiated
  // before Firebase.initializeApp() runs. This prevents the `[core/no-app]`
  // crash on platforms where Firebase isn't configured or initialization
  // failed.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  bool get _firebaseAvailable => Firebase.apps.isNotEmpty;

  Future<void> signInAnonymously() async {
    // If Firebase hasn't been initialized (e.g., main initialization failed
    // or flutterfire options are missing on desktop), try to initialize it
    // on-demand. This attempts to give a better error message and a path
    // forward for desktop (Windows) where `firebase_options.dart` is often
    // required.
    if (!_firebaseAvailable) {
      try {
        await Firebase.initializeApp();
        debugPrint('Firebase inicializado on-demand.');
      } catch (e) {
        // Provide an actionable error message instead of a raw platform
        // exception so the developer knows to run the FlutterFire config.
        throw Exception(
          'Firebase não está inicializado. Impossível autenticar. Detalhes: $e\n'
          'Observação: em plataformas desktop (Windows) você provavelmente precisa executar `flutterfire configure`\n'
          'para gerar `lib/firebase_options.dart` e então chamar `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` em `main()` antes de usar Firebase.',
        );
      }
    }

    try {
      await _auth.signInAnonymously();
      debugPrint('Login anônimo realizado com sucesso!');
    } catch (e) {
      debugPrint('Erro ao fazer login anônimo: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!_firebaseAvailable) return;
    await _auth.signOut();
  }

  bool get isSignedIn => _firebaseAvailable && _auth.currentUser != null;

  /// Backup apenas do banco de dados (método original mantido para compatibilidade)
  Future<String> backupDatabase() async {
    if (!_firebaseAvailable || _auth.currentUser == null) {
      throw Exception(
        'Usuário não autenticado ou Firebase não inicializado. Faça login primeiro.',
      );
    }

    try {
      // Obter caminho do banco de dados
      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, 'dayapp.db'));

      if (!await dbFile.exists()) {
        throw Exception('Banco de dados não encontrado.');
      }

      // Gerar código de recuperação
      const uuid = Uuid();
      final backupCode = uuid.v4();

      // Upload para Firebase Storage
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'dayapp_backup_$timestamp.db';
      final ref = _storage.ref().child('backups/$backupCode/$fileName');

      await ref.putFile(dbFile);

      debugPrint('Backup realizado com sucesso! Código: $backupCode');
      return backupCode;
    } catch (e) {
      debugPrint('Erro ao fazer backup: $e');
      rethrow;
    }
  }

  /// Backup completo: banco de dados + vídeos para Firebase Storage
  Future<String> backupComplete({void Function(String)? onProgress}) async {
    if (!_firebaseAvailable || _auth.currentUser == null) {
      throw Exception(
        'Usuário não autenticado ou Firebase não inicializado. Faça login primeiro.',
      );
    }

    try {
      onProgress?.call('Iniciando backup completo...');

      // Gerar código de recuperação único
      const uuid = Uuid();
      final backupCode = uuid.v4();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

      // 1. Backup do banco de dados
      onProgress?.call('Fazendo backup do banco de dados...');
      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, 'dayapp.db'));

      if (!await dbFile.exists()) {
        throw Exception('Banco de dados não encontrado.');
      }

      final dbFileName = 'dayapp_backup_$timestamp.db';
      final dbRef = _storage.ref().child('backups/$backupCode/$dbFileName');
      await dbRef.putFile(dbFile);

      // 2. Backup dos vídeos
      onProgress?.call('Fazendo backup dos vídeos...');
      final videosDir = await VideoFileHelper.getVideosDirectory();
      final videoFiles = videosDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.mp4'))
          .toList();

      if (videoFiles.isNotEmpty) {
        for (int i = 0; i < videoFiles.length; i++) {
          final videoFile = videoFiles[i];
          final videoFileName = path.basename(videoFile.path);
          onProgress?.call(
            'Enviando vídeo ${i + 1}/${videoFiles.length}: $videoFileName',
          );

          final videoRef = _storage.ref().child(
            'backups/$backupCode/videos/$videoFileName',
          );
          await videoRef.putFile(videoFile);
        }
      }

      onProgress?.call('Backup completo realizado com sucesso!');
      debugPrint(
        'Backup completo realizado! Código: $backupCode (${videoFiles.length} vídeos)',
      );
      return backupCode;
    } catch (e) {
      debugPrint('Erro ao fazer backup completo: $e');
      rethrow;
    }
  }

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

      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      encoder.addDirectory(backupDir);
      encoder.close();

      // Limpar diretório temporário
      await backupDir.delete(recursive: true);

      onProgress?.call('Backup criado com sucesso!');
      debugPrint('Arquivo ZIP criado: $zipPath');
      return zipPath;
    } catch (e) {
      debugPrint('Erro ao criar arquivo de backup: $e');
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
      final result = await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Backup DayApp',
        text: 'Backup completo do DayApp com banco de dados e vídeos',
      );

      debugPrint('Compartilhamento: ${result.status}');
    } catch (e) {
      debugPrint('Erro ao compartilhar backup: $e');
      rethrow;
    }
  }

  Future<List<Reference>> listBackups([String? backupCode]) async {
    if (!_firebaseAvailable) {
      throw Exception('Firebase não está inicializado.');
    }

    try {
      final code = backupCode ?? _auth.currentUser!.uid;
      final ref = _storage.ref().child('backups/$code');
      final result = await ref.listAll();

      // Filtrar apenas arquivos .db e ordenar por data (mais recente primeiro)
      final backups = result.items
          .where((item) => item.name.endsWith('.db'))
          .toList();
      backups.sort((a, b) => b.name.compareTo(a.name)); // Ordem decrescente

      return backups;
    } catch (e) {
      debugPrint('Erro ao listar backups: $e');
      rethrow;
    }
  }

  /// Restaura apenas o banco de dados (método original)
  Future<void> restoreDatabase(Reference backupRef) async {
    if (!_firebaseAvailable || _auth.currentUser == null) {
      throw Exception('Usuário não autenticado ou Firebase não inicializado.');
    }

    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, 'dayapp.db'));

      // Fazer backup do atual antes de restaurar (opcional)
      if (await dbFile.exists()) {
        final backupCurrent = File(path.join(dbPath, 'dayapp_backup_local.db'));
        await dbFile.copy(backupCurrent.path);
      }

      // Baixar e substituir
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path, 'temp_restore.db'));

      await backupRef.writeToFile(tempFile);
      await tempFile.copy(dbFile.path);
      await tempFile.delete();

      debugPrint('Restauração realizada com sucesso!');
    } catch (e) {
      debugPrint('Erro ao restaurar: $e');
      rethrow;
    }
  }

  /// Restaura backup completo do Firebase Storage (banco + vídeos)
  Future<void> restoreComplete(
    String backupCode, {
    void Function(String)? onProgress,
  }) async {
    if (!_firebaseAvailable || _auth.currentUser == null) {
      throw Exception('Usuário não autenticado ou Firebase não inicializado.');
    }

    try {
      onProgress?.call('Iniciando restauração...');

      // 1. Listar arquivos do backup
      final ref = _storage.ref().child('backups/$backupCode');
      final result = await ref.listAll();

      // Encontrar arquivo do banco de dados
      final dbFile = result.items.firstWhere(
        (item) => item.name.endsWith('.db'),
        orElse: () =>
            throw Exception('Banco de dados não encontrado no backup'),
      );

      // 2. Fazer backup do banco atual
      onProgress?.call('Fazendo backup do banco atual...');
      final dbPath = await getDatabasesPath();
      final currentDb = File(path.join(dbPath, 'dayapp.db'));

      if (await currentDb.exists()) {
        final backupCurrent = File(path.join(dbPath, 'dayapp_backup_local.db'));
        await currentDb.copy(backupCurrent.path);
      }

      // 3. Restaurar banco de dados
      onProgress?.call('Restaurando banco de dados...');
      final tempDir = await getTemporaryDirectory();
      final tempDbFile = File(path.join(tempDir.path, 'temp_restore.db'));

      await dbFile.writeToFile(tempDbFile);
      await tempDbFile.copy(currentDb.path);
      await tempDbFile.delete();

      // 4. Verificar se há vídeos no backup
      onProgress?.call('Verificando vídeos...');
      final videosRef = ref.child('videos');
      try {
        final videosResult = await videosRef.listAll();

        if (videosResult.items.isNotEmpty) {
          // Limpar vídeos atuais
          onProgress?.call('Limpando vídeos atuais...');
          final videosDir = await VideoFileHelper.getVideosDirectory();
          final currentVideos = videosDir.listSync();
          for (final file in currentVideos) {
            if (file is File) {
              await file.delete();
            }
          }

          // Restaurar vídeos
          for (int i = 0; i < videosResult.items.length; i++) {
            final videoRef = videosResult.items[i];
            onProgress?.call(
              'Restaurando vídeo ${i + 1}/${videosResult.items.length}...',
            );

            final videoFile = File(path.join(videosDir.path, videoRef.name));
            await videoRef.writeToFile(videoFile);
          }
        }
      } catch (e) {
        debugPrint(
          'Nenhum vídeo encontrado no backup ou erro ao restaurar vídeos: $e',
        );
      }

      onProgress?.call('Restauração completa realizada com sucesso!');
      debugPrint('Restauração completa concluída!');
    } catch (e) {
      debugPrint('Erro ao restaurar backup completo: $e');
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
      final restoredDb = File(path.join(extractDir.path, 'dayapp.db'));
      if (await restoredDb.exists()) {
        await restoredDb.copy(currentDb.path);
      } else {
        throw Exception('Banco de dados não encontrado no arquivo de backup');
      }

      // 3. Restaurar vídeos
      onProgress?.call('Restaurando vídeos...');
      final videosRestoreDir = Directory(path.join(extractDir.path, 'videos'));

      if (await videosRestoreDir.exists()) {
        // Limpar vídeos atuais
        final videosDir = await VideoFileHelper.getVideosDirectory();
        final currentVideos = videosDir.listSync();
        for (final file in currentVideos) {
          if (file is File) {
            await file.delete();
          }
        }

        // Copiar vídeos restaurados
        final restoredVideos = videosRestoreDir.listSync();
        for (int i = 0; i < restoredVideos.length; i++) {
          if (restoredVideos[i] is File) {
            final videoFile = restoredVideos[i] as File;
            final videoFileName = path.basename(videoFile.path);
            onProgress?.call(
              'Restaurando vídeo ${i + 1}/${restoredVideos.length}...',
            );

            final destFile = File(path.join(videosDir.path, videoFileName));
            await videoFile.copy(destFile.path);
          }
        }
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
