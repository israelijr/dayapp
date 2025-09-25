import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/historia.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    print('DatabaseHelper: inicializando banco de dados...');
    _database = await _initDatabase();
    print('DatabaseHelper: banco de dados inicializado');
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      print('DatabaseHelper: obtendo caminho do banco de dados...');
      final dbPath = await getDatabasesPath();
      print('DatabaseHelper: caminho do banco: $dbPath');
      final path = join(dbPath, 'dayapp.db');
      print('DatabaseHelper: abrindo banco em $path');
      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, stack) {
      print('DatabaseHelper: erro ao inicializar banco: $e');
      print('DatabaseHelper: stacktrace: $stack');
      rethrow;
    }
  }

  Future _onCreate(Database db, int version) async {
    print('DatabaseHelper: criando tabelas...');
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
      print('DatabaseHelper: tabela users criada');
      await db.execute('''
        CREATE TABLE historia (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          assunto TEXT,
          titulo TEXT NOT NULL,
          data TIMESTAMP NOT NULL,
          tag TEXT,
          descricao TEXT,
          sentimento TEXT,
          emoticon TEXT,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          data_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          foto_historia TEXT,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      print('DatabaseHelper: tabela historia criada');
      await db.execute('''
        CREATE TABLE historia_fotos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          foto BLOB NOT NULL,
          legenda TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      print('DatabaseHelper: tabela historia_fotos criada');
      await db.execute(
        'CREATE INDEX idx_historia_user_id ON historia(user_id);',
      );
      await db.execute('CREATE INDEX idx_historia_data ON historia(data);');
      await db.execute('CREATE INDEX idx_historia_tag ON historia(tag);');
      await db.execute('CREATE INDEX idx_users_email ON users(email);');
      print('DatabaseHelper: índices criados');
    } catch (e, stack) {
      print('DatabaseHelper: erro ao criar tabelas: $e');
      print('DatabaseHelper: stacktrace: $stack');
      rethrow;
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE historia ADD COLUMN emoticon TEXT;');
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
