import 'database_helper.dart';

class EvidenciaDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('EVIDENCIA');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('EVIDENCIA', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'EVIDENCIA',
      data,
      where: 'ID_EVIDENCIA = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'EVIDENCIA',
      where: 'ID_EVIDENCIA = ?',
      whereArgs: [id],
    );
  }
}
