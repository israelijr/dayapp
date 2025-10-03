import 'dart:io';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import '../models/historia.dart';
import '../helpers/video_file_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    debugPrint('DatabaseHelper: inicializando banco de dados...');
    _database = await _initDatabase();
    debugPrint('DatabaseHelper: banco de dados inicializado');
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      debugPrint('DatabaseHelper: obtendo caminho do banco de dados...');
      final dbPath = await getDatabasesPath();
      debugPrint('DatabaseHelper: caminho do banco: $dbPath');
      final path = p.join(dbPath, 'dayapp.db');
      debugPrint('DatabaseHelper: abrindo banco em $path');
      return await openDatabase(
        path,
        version: 7,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, stack) {
      debugPrint('DatabaseHelper: erro ao inicializar banco: $e');
      debugPrint('DatabaseHelper: stacktrace: $stack');
      rethrow;
    }
  }

  Future _onCreate(Database db, int version) async {
    debugPrint('DatabaseHelper: criando tabelas...');
    try {
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          nome TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          senha TEXT NOT NULL,
          dt_nascimento TIMESTAMP,
          foto_perfil TEXT
        );
      ''');
      debugPrint('DatabaseHelper: tabela users criada');
      await db.execute('''
        CREATE TABLE historia (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          assunto TEXT,
          titulo TEXT NOT NULL,
          data TIMESTAMP NOT NULL,
          tag TEXT,
          grupo TEXT,
          arquivado TEXT,
          descricao TEXT,
          sentimento TEXT,
          emoticon TEXT,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          data_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          foto_historia TEXT,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      debugPrint('DatabaseHelper: tabela historia criada');
      await db.execute('''
        CREATE TABLE historia_fotos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          foto BLOB NOT NULL,
          legenda TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      debugPrint('DatabaseHelper: tabela historia_fotos criada');
      await db.execute('''
        CREATE TABLE historia_audios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          audio BLOB NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      debugPrint('DatabaseHelper: tabela historia_audios criada');
      await db.execute('''
        CREATE TABLE historia_videos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          video BLOB NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          thumbnail BLOB,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      debugPrint('DatabaseHelper: tabela historia_videos criada');
      await db.execute('''
        CREATE TABLE grupos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      debugPrint('DatabaseHelper: tabela grupos criada');
      await db.execute(
        'CREATE INDEX idx_historia_user_id ON historia(user_id);',
      );
      await db.execute('CREATE INDEX idx_historia_data ON historia(data);');
      await db.execute('CREATE INDEX idx_historia_tag ON historia(tag);');
      await db.execute('CREATE INDEX idx_users_email ON users(email);');
      debugPrint('DatabaseHelper: índices criados');
    } catch (e, stack) {
      debugPrint('DatabaseHelper: erro ao criar tabelas: $e');
      debugPrint('DatabaseHelper: stacktrace: $stack');
      rethrow;
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE historia ADD COLUMN emoticon TEXT;');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE historia ADD COLUMN grupo TEXT;');
      await db.execute('ALTER TABLE historia ADD COLUMN arquivado TEXT;');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE grupos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      debugPrint('DatabaseHelper: tabela grupos criada na upgrade');
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE historia ADD COLUMN arquivado TEXT;');
        debugPrint('DatabaseHelper: coluna arquivado adicionada');
      } catch (e) {
        debugPrint('DatabaseHelper: coluna arquivado já existe: $e');
      }
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE historia_audios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          audio BLOB NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      debugPrint('DatabaseHelper: tabela historia_audios criada na upgrade');
      await db.execute('''
        CREATE TABLE historia_videos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          video BLOB NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          thumbnail BLOB,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      debugPrint('DatabaseHelper: tabela historia_videos criada na upgrade');
    }
    if (oldVersion < 7) {
      // Migração: BLOB para sistema de arquivos
      debugPrint(
        'DatabaseHelper: iniciando migração v6 -> v7 (vídeos para arquivos)',
      );

      // Criar nova tabela com caminhos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS historia_videos_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          video_path TEXT NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          thumbnail_path TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      debugPrint('DatabaseHelper: tabela historia_videos_new criada');

      // Tentar migrar dados existentes (apenas vídeos pequenos < 2MB)
      try {
        final videos = await db.query('historia_videos', limit: 100);
        debugPrint(
          'DatabaseHelper: encontrados ${videos.length} vídeos para migrar',
        );

        int migrated = 0;
        int skipped = 0;

        for (final video in videos) {
          try {
            final videoBlob = video['video'];
            if (videoBlob != null && videoBlob is List<int>) {
              final videoData = Uint8List.fromList(videoBlob);

              // Só migra vídeos < 2MB (que ainda conseguem ser lidos)
              if (videoData.length < 2000000) {
                final historiaId = video['historia_id'] as int;

                // Salvar no sistema de arquivos
                final videosDir = await VideoFileHelper.getVideosDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final fileName =
                    'video_${historiaId}_${timestamp}_migrated.mp4';
                final filePath = p.join(videosDir.path, fileName);

                final file = File(filePath);
                await file.writeAsBytes(videoData);

                // Inserir na nova tabela
                await db.insert('historia_videos_new', {
                  'historia_id': historiaId,
                  'video_path': filePath,
                  'legenda': video['legenda'],
                  'duracao': video['duracao'],
                  'thumbnail_path': null,
                });

                migrated++;
                debugPrint(
                  'DatabaseHelper: vídeo $migrated migrado (${videoData.length} bytes)',
                );
              } else {
                skipped++;
                debugPrint(
                  'DatabaseHelper: vídeo muito grande ignorado (${videoData.length} bytes)',
                );
              }
            }
          } catch (e) {
            debugPrint('DatabaseHelper: erro ao migrar vídeo individual: $e');
            skipped++;
          }
        }

        debugPrint(
          'DatabaseHelper: migração concluída - $migrated migrados, $skipped ignorados',
        );
      } catch (e) {
        debugPrint(
          'DatabaseHelper: tabela antiga não existe ou erro na migração: $e',
        );
      }

      // Dropar tabela antiga e renomear nova
      await db.execute('DROP TABLE IF EXISTS historia_videos');
      await db.execute(
        'ALTER TABLE historia_videos_new RENAME TO historia_videos',
      );
      debugPrint('DatabaseHelper: migração v6 -> v7 concluída');
    }
  }

  Future<Historia?> getHistoria(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'historia',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Historia.fromMap(maps.first);
    }
    return null;
  }

  /// Close any open database and reset the cached instance so the next call
  /// to `database` will re-open the (possibly replaced) DB file.
  Future<void> resetDatabase() async {
    try {
      if (_database != null) {
        debugPrint('DatabaseHelper: closing existing database connection...');
        await _database!.close();
        _database = null;
        debugPrint(
          'DatabaseHelper: database connection closed and cache cleared',
        );
      }
    } catch (e) {
      debugPrint('DatabaseHelper: erro ao resetar o banco: $e');
      rethrow;
    }
  }
}
