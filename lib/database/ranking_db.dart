import 'database_helper.dart';

class RankingDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('RANKING_HISTORICO');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('RANKING_HISTORICO', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'RANKING_HISTORICO',
      data,
      where: 'ID_RANKING = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'RANKING_HISTORICO',
      where: 'ID_RANKING = ?',
      whereArgs: [id],
    );
  }
}
