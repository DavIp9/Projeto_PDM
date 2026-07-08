import 'database_helper.dart';

class RequisitoDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('REQUISITO');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('REQUISITO', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'REQUISITO',
      data,
      where: 'ID_REQUISITO = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'REQUISITO',
      where: 'ID_REQUISITO = ?',
      whereArgs: [id],
    );
  }
}
