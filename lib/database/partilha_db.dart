import 'database_helper.dart';

class PartilhaDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('PARTILHA');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('PARTILHA', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'PARTILHA',
      data,
      where: 'ID_PARTILHA = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'PARTILHA',
      where: 'ID_PARTILHA = ?',
      whereArgs: [id],
    );
  }
}
