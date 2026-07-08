import 'database_helper.dart';

class FicheiroEvidenciaDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('FICHEIROSEVIDENCIA');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('FICHEIROSEVIDENCIA', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'FICHEIROSEVIDENCIA',
      data,
      where: 'ID_FICHEIROEVIDENCIA = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'FICHEIROSEVIDENCIA',
      where: 'ID_FICHEIROEVIDENCIA = ?',
      whereArgs: [id],
    );
  }
}
