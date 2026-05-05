import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/badge_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('softinsa_badges.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE badges (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  area TEXT NOT NULL,
  level TEXT NOT NULL,
  points INTEGER NOT NULL,
  isRecommended INTEGER NOT NULL
)
''');
    // We can add more tables later like users, wallet, requests
  }

  Future<void> syncDataFromMock() async {
    final db = await instance.database;
    final String response = await rootBundle.loadString('assets/data.json');
    final data = await json.decode(response);

    List<dynamic> badges = data['badges'];
    
    Batch batch = db.batch();
    for (var badgeJson in badges) {
      BadgeModel badge = BadgeModel.fromJson(badgeJson);
      batch.insert(
        'badges',
        badge.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
  
  Future<List<BadgeModel>> getAllBadges() async {
    final db = await instance.database;
    final result = await db.query('badges');
    return result.map((json) => BadgeModel.fromMap(json)).toList();
  }
}
