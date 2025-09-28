import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import '../models/historia.dart';

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
        version: 5,
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
}
