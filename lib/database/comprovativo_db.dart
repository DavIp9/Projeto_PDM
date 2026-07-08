import 'database_helper.dart';

class ComprovativoDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('COMPROVATIVO');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('COMPROVATIVO', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'COMPROVATIVO',
      data,
      where: 'ID_COMPROVATIVO = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'COMPROVATIVO',
      where: 'ID_COMPROVATIVO = ?',
      whereArgs: [id],
    );
  }
}
