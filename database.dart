import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sms_scheduler.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone TEXT,
            message TEXT,
            scheduledAt INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertMessage(String phone, String message, int scheduledAt) async {
    final db = await database;
    return await db.insert('messages', {'phone': phone, 'message': message, 'scheduledAt': scheduledAt});
  }

  Future<int> insertTemplate(String message) async {
    final db = await database;
    return await db.insert('templates', {'message': message});
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final db = await database;
    return await db.query('messages');
  }

  Future<List<Map<String, dynamic>>> getTemplates() async {
    final db = await database;
    return await db.query('templates');
  }

  Future<int> deleteMessage(int id) async {
    final db = await database;
    return await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTemplate(int id) async {
    final db = await database;
    return await db.delete('templates', where: 'id = ?', whereArgs: [id]);
  }
}