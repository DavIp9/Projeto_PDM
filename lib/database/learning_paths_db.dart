import 'database_helper.dart';

class LearningPathDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('LEARNING_PATHS');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('LEARNING_PATHS', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'LEARNING_PATHS',
      data,
      where: 'ID_LEARNING_PATH = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'LEARNING_PATHS',
      where: 'ID_LEARNING_PATH = ?',
      whereArgs: [id],
    );
  }
}
