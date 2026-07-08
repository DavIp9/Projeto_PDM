import 'database_helper.dart';

class ValidacaoCandidaturaDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('VALIDACAOCANDIDATURA');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('VALIDACAOCANDIDATURA', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'VALIDACAOCANDIDATURA',
      data,
      where: 'ID_VALIDACAO = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'VALIDACAOCANDIDATURA',
      where: 'ID_VALIDACAO = ?',
      whereArgs: [id],
    );
  }
}
