import 'database_helper.dart';

class PermissaoDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('PERMISSOES');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('PERMISSOES', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'PERMISSOES',
      data,
      where: 'IDPERMISSAO = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'PERMISSOES',
      where: 'IDPERMISSAO = ?',
      whereArgs: [id],
    );
  }
}
