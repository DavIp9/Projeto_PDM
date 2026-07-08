import 'database_helper.dart';

class AlertaGlobalDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('ALERTAGLOBAL');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('ALERTAGLOBAL', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'ALERTAGLOBAL',
      data,
      where: 'IDALERTAGLOBAL = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'ALERTAGLOBAL',
      where: 'IDALERTAGLOBAL = ?',
      whereArgs: [id],
    );
  }
}
