import 'database_helper.dart';

class CandidaturaDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('CANDIDATURA');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('CANDIDATURA', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'CANDIDATURA',
      data,
      where: 'ID_CANDIDATURA = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'CANDIDATURA',
      where: 'ID_CANDIDATURA = ?',
      whereArgs: [id],
    );
  }
}
