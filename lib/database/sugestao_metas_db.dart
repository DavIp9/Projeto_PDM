import 'database_helper.dart';

class SugestaoMetasDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('SUGESTAOMETAS');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('SUGESTAOMETAS', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'SUGESTAOMETAS',
      data,
      where: 'ID_SUGESTAO = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'SUGESTAOMETAS',
      where: 'ID_SUGESTAO = ?',
      whereArgs: [id],
    );
  }
}
