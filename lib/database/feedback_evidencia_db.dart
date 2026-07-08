import 'database_helper.dart';

class FeedbackEvidenciaDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('FEEDBACKEVIDENCIA');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('FEEDBACKEVIDENCIA', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'FEEDBACKEVIDENCIA',
      data,
      where: 'IDFEEDBACK = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'FEEDBACKEVIDENCIA',
      where: 'IDFEEDBACK = ?',
      whereArgs: [id],
    );
  }
}
