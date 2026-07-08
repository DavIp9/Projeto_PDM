import 'database_helper.dart';

class ConfiguracaoDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('CONFIGURACOES');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('CONFIGURACOES', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'CONFIGURACOES',
      data,
      where: 'IDCONFIGURACAO = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'CONFIGURACOES',
      where: 'IDCONFIGURACAO = ?',
      whereArgs: [id],
    );
  }
}
