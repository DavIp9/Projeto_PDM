import 'database_helper.dart';

class NotificacaoDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('NOTIFICACOES');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('NOTIFICACOES', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'NOTIFICACOES',
      data,
      where: 'ID_NOTIFICACAO = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'NOTIFICACOES',
      where: 'ID_NOTIFICACAO = ?',
      whereArgs: [id],
    );
  }
}
