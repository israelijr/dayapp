import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

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
}
