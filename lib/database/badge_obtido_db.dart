import 'database_helper.dart';

class BadgeObtidoDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('BADGE_OBTIDO');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('BADGE_OBTIDO', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'BADGE_OBTIDO',
      data,
      where: 'ID_BADGEOBTIDO = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'BADGE_OBTIDO',
      where: 'ID_BADGEOBTIDO = ?',
      whereArgs: [id],
    );
  }
}
