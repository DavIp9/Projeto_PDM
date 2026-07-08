import 'database_helper.dart';

class PerfilPermissaoDB {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('PERFILPERMISSAO');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('PERFILPERMISSAO', data);
  }

  Future<int> delete(
    int idPerfil,
    int idPermissao,
  ) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'PERFILPERMISSAO',
      where: 'ID_PERFIL = ? AND IDPERMISSAO = ?',
      whereArgs: [idPerfil, idPermissao],
    );
  }
}
