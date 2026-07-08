import 'database_helper.dart';

class BadgeDB {
  Future<List<Map<String, dynamic>>> listarBadges() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('BADGE');
  }

  Future<Map<String, dynamic>?> obterPorId(int id) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'BADGE',
      where: 'ID_BADGE = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<int> inserir(Map<String, dynamic> badge) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('BADGE', badge);
  }

  Future<int> atualizar(int id, Map<String, dynamic> badge) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'BADGE',
      badge,
      where: 'ID_BADGE = ?',
      whereArgs: [id],
    );
  }

  Future<int> apagar(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'BADGE',
      where: 'ID_BADGE = ?',
      whereArgs: [id],
    );
  }
}
