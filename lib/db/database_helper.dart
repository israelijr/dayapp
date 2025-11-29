import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../helpers/video_file_helper.dart';
import '../models/historia.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'dayapp.db');
      return await openDatabase(
        path,
        version: 11,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future _onCreate(Database db, int version) async {
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
          excluido TEXT,
          data_exclusao TIMESTAMP,
          descricao TEXT,
          sentimento TEXT,
          emoticon TEXT,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          data_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          foto_historia TEXT,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE historia_fotos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          foto BLOB NOT NULL,
          legenda TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
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
      await db.execute('''
        CREATE TABLE historia_videos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          video_path TEXT NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          thumbnail_path TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE grupos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          emoticon TEXT,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE notification_scheduled (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          notification_id INTEGER NOT NULL,
          scheduled_time TEXT NOT NULL,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      await db.execute(
        'CREATE INDEX idx_historia_user_id ON historia(user_id);',
      );
      await db.execute('CREATE INDEX idx_historia_data ON historia(data);');
      await db.execute('CREATE INDEX idx_historia_tag ON historia(tag);');
      await db.execute('CREATE INDEX idx_users_email ON users(email);');
    } catch (e) {
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
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE historia ADD COLUMN arquivado TEXT;');
      } catch (e) {
        // Column may already exist
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
      await db.execute('''
        CREATE TABLE historia_videos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          video_path TEXT NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          thumbnail_path TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
    }
    if (oldVersion < 7) {
      // Migração: BLOB para sistema de arquivos
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

      // Tentar migrar dados existentes (apenas vídeos pequenos < 2MB)
      try {
        final videos = await db.query('historia_videos', limit: 100);

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
              }
            }
          } catch (e) {
            // Skip video on error
          }
        }
      } catch (e) {
        // Old table doesn't exist or migration error
      }

      // Dropar tabela antiga e renomear nova
      await db.execute('DROP TABLE IF EXISTS historia_videos');
      await db.execute(
        'ALTER TABLE historia_videos_new RENAME TO historia_videos',
      );
    }
    if (oldVersion < 8) {
      try {
        await db.execute('ALTER TABLE historia ADD COLUMN excluido TEXT;');
        await db.execute(
          'ALTER TABLE historia ADD COLUMN data_exclusao TIMESTAMP;',
        );
      } catch (e) {
        // Columns may already exist
      }
    }
    if (oldVersion < 9) {
      // Garantir que a tabela historia_videos tenha a estrutura correta (video_path)
      try {
        // Verificar se a tabela existe e tem a estrutura correta
        final result = await db.rawQuery('PRAGMA table_info(historia_videos)');
        final hasVideoPath = result.any(
          (column) => column['name'] == 'video_path',
        );

        if (!hasVideoPath) {
          // Tabela ainda usa BLOB, precisa migrar
          // Criar nova tabela com estrutura correta
          await db.execute('''
            CREATE TABLE IF NOT EXISTS historia_videos_fixed (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              historia_id INTEGER NOT NULL,
              video_path TEXT NOT NULL,
              legenda TEXT,
              duracao INTEGER,
              thumbnail_path TEXT,
              FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
            );
          ''');

          // Dropar tabela antiga e renomear nova
          await db.execute('DROP TABLE IF EXISTS historia_videos');
          await db.execute(
            'ALTER TABLE historia_videos_fixed RENAME TO historia_videos',
          );
        }
      } catch (e) {
        // Error correcting table structure
      }
    }
    if (oldVersion < 10) {
      // Adicionar tabela de notificações agendadas
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notification_scheduled (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            historia_id INTEGER NOT NULL,
            notification_id INTEGER NOT NULL,
            scheduled_time TEXT NOT NULL,
            FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
          );
        ''');
      } catch (e) {
        // Error creating notification_scheduled table
      }
    }
    if (oldVersion < 11) {
      try {
        await db.execute('ALTER TABLE grupos ADD COLUMN emoticon TEXT;');
      } catch (e) {
        // Column may already exist
      }
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
        await _database!.close();
        _database = null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Métodos para gerenciar notificações agendadas

  /// Agenda uma notificação para uma história
  Future<void> scheduleNotificationForHistoria(
    int historiaId,
    int notificationId,
    DateTime scheduledTime,
  ) async {
    final db = await database;

    // Cancela notificação existente se houver
    await db.delete(
      'notification_scheduled',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );

    // Insere nova notificação
    await db.insert('notification_scheduled', {
      'historia_id': historiaId,
      'notification_id': notificationId,
      'scheduled_time': scheduledTime.toIso8601String(),
    });
  }

  /// Busca notificação agendada para uma história
  Future<Map<String, dynamic>?> getScheduledNotification(int historiaId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'notification_scheduled',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  /// Cancela notificação agendada para uma história
  Future<void> cancelScheduledNotification(int historiaId) async {
    final db = await database;
    await db.delete(
      'notification_scheduled',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );
  }
}
