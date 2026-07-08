import 'database_helper.dart';

class TimelineDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('TIMELINEEVOLUCAO');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('TIMELINEEVOLUCAO', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'TIMELINEEVOLUCAO',
      data,
      where: 'ID_TIMELINE = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'TIMELINEEVOLUCAO',
      where: 'ID_TIMELINE = ?',
      whereArgs: [id],
    );
  }
}
