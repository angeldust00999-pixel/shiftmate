import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-memory storage untuk web platform
  static final Map<String, List<Map<String, dynamic>>> _memoryDatabase = {
    'users': [],
    'menus': [],
    'shifts': [],
    'transactions': [],
    'stocks': [],
    'positions': [
      {
        'id': 1,
        'name': 'Lead Barista',
        'description': 'Penanggung jawab barista',
        'created_at': '2024-01-01T00:00:00.000',
      },
      {
        'id': 2,
        'name': 'Barista',
        'description': 'Barista biasa',
        'created_at': '2024-01-01T00:00:00.000',
      },
      {
        'id': 3,
        'name': 'Cashier',
        'description': 'Kasir',
        'created_at': '2024-01-01T00:00:00.000',
      },
      {
        'id': 4,
        'name': 'Kitchen',
        'description': 'Dapur',
        'created_at': '2024-01-01T00:00:00.000',
      },
    ],
  };
  static int _nextId = 5;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) {
      // Untuk web, return null (menggunakan in-memory)
      return null;
    }
    if (_database != null) return _database!;
    _database = await _initDB('shiftmate_cafe.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE menus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price INTEGER NOT NULL,
        stock INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barista_name TEXT NOT NULL,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        position TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menu_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        total_price INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (menu_id) REFERENCES menus (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stocks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE positions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Insert default positions
    await db.insert('positions', {
      'name': 'Lead Barista',
      'description': 'Penanggung jawab barista',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('positions', {
      'name': 'Barista',
      'description': 'Barista biasa',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('positions', {
      'name': 'Cashier',
      'description': 'Kasir',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('positions', {
      'name': 'Kitchen',
      'description': 'Dapur',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          role TEXT NOT NULL,
          username TEXT NOT NULL,
          password TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    if (kIsWeb) {
      // Untuk web, simpan ke in-memory
      final cleaned = Map<String, dynamic>.from(data)..remove('id');
      cleaned['id'] = _nextId++;
      _memoryDatabase[table]?.add(cleaned);
      return cleaned['id'];
    }
    final db = await database;
    if (db == null) return 0;
    final cleaned = Map<String, dynamic>.from(data)..remove('id');
    return await db.insert(table, cleaned);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    if (kIsWeb) {
      // Untuk web, ambil dari in-memory
      return List<Map<String, dynamic>>.from(_memoryDatabase[table] ?? [])
        ..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    }
    final db = await database;
    if (db == null) return [];
    return await db.query(table, orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> getById(String table, int id) async {
    if (kIsWeb) {
      // Untuk web, cari di in-memory
      try {
        return (_memoryDatabase[table] ?? []).firstWhere(
          (item) => item['id'] == id,
        );
      } catch (e) {
        return null;
      }
    }
    final db = await database;
    if (db == null) return null;
    final result = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    if (kIsWeb) {
      // Untuk web, update di in-memory
      final list = _memoryDatabase[table] ?? [];
      final index = list.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        final cleaned = Map<String, dynamic>.from(data);
        cleaned['id'] = id;
        list[index] = cleaned;
        return 1;
      }
      return 0;
    }
    final db = await database;
    if (db == null) return 0;
    final cleaned = Map<String, dynamic>.from(data)..remove('id');
    return await db.update(table, cleaned, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    if (kIsWeb) {
      // Untuk web, hapus dari in-memory
      final list = _memoryDatabase[table] ?? [];
      final index = list.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        list.removeAt(index);
        return 1;
      }
      return 0;
    }
    final db = await database;
    if (db == null) return 0;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    if (!kIsWeb) {
      final db = await database;
      if (db != null) {
        await db.close();
      }
    }
  }
}
