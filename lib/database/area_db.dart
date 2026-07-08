import 'database_helper.dart';

class ServiceLineDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('SERVICE_LINE');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('SERVICE_LINE', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'SERVICE_LINE',
      data,
      where: 'ID_SERVICE_LINE = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'SERVICE_LINE',
      where: 'ID_SERVICE_LINE = ?',
      whereArgs: [id],
    );
  }
}
