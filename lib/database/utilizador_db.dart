import 'database_helper.dart';

class UtilizadorDB {
  Future<List<Map<String, dynamic>>> listarUtilizadores() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('UTILIZADOR');
  }

  Future<Map<String, dynamic>?> obterPorId(int id) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'UTILIZADOR',
      where: 'ID_UTILIZADOR = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<Map<String, dynamic>?> obterPorEmail(String email) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'UTILIZADOR',
      where: 'EMAIL = ?',
      whereArgs: [email],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<int> inserir(Map<String, dynamic> utilizador) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert('UTILIZADOR', {
      ...utilizador,
      'ESTADO': 'Pendente',
      'PRIMEIRO_LOGIN': 1,
    });
  }

  Future<int> atualizar(int id, Map<String, dynamic> utilizador) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'UTILIZADOR',
      utilizador,
      where: 'ID_UTILIZADOR = ?',
      whereArgs: [id],
    );
  }

  Future<int> apagar(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'UTILIZADOR',
      where: 'ID_UTILIZADOR = ?',
      whereArgs: [id],
    );
  }

  Future<int> ativarUtilizador(String email) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'UTILIZADOR',
      {
        'ESTADO': 'Ativo',
      },
      where: 'EMAIL = ?',
      whereArgs: [email],
    );
  }

  Future<int> alterarPasswordPrimeiroLogin(
    String email,
    String novaPassword,
  ) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'UTILIZADOR',
      {
        'PASSWORD': novaPassword,
        'PRIMEIRO_LOGIN': 0,
      },
      where: 'EMAIL = ?',
      whereArgs: [email],
    );
  }
}
