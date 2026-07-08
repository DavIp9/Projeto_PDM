import 'database_helper.dart';

class ExportacaoDadosDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('EXPORTACAODADOS');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('EXPORTACAODADOS', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'EXPORTACAODADOS',
      data,
      where: 'ID_EXPORTACAO = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'EXPORTACAODADOS',
      where: 'ID_EXPORTACAO = ?',
      whereArgs: [id],
    );
  }
}
