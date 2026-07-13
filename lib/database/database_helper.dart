import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/badge_model.dart';
import '../models/utilizador_model.dart';
import '../models/area_model.dart';
import '../models/requisito_model.dart';
import 'database_seed.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('softinsa_badges.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _createDB,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE PERFIL (
        ID_PERFIL INTEGER PRIMARY KEY,
        NOME_PERFIL TEXT NOT NULL,
        DESCRICAO TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE PERMISSOES (
        IDPERMISSAO INTEGER PRIMARY KEY,
        NOME TEXT NOT NULL,
        ESTADO TEXT NOT NULL,
        CATEGORIA TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE PERFILPERMISSAO (
        ID_PERFIL INTEGER NOT NULL,
        IDPERMISSAO INTEGER NOT NULL,
        PRIMARY KEY (ID_PERFIL, IDPERMISSAO),
        FOREIGN KEY (ID_PERFIL) REFERENCES PERFIL(ID_PERFIL),
        FOREIGN KEY (IDPERMISSAO) REFERENCES PERMISSOES(IDPERMISSAO)
      )
    ''');

    await db.execute('''
      CREATE TABLE LEARNING_PATHS (
        ID_LEARNING_PATH INTEGER PRIMARY KEY,
        NOME_LEARNINGPATH TEXT NOT NULL,
        DESCRICAO TEXT NOT NULL,
        URLIMAGEM TEXT NOT NULL,
        FASE TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE SERVICE_LINE (
        ID_SERVICE_LINE INTEGER PRIMARY KEY,
        ID_LEARNING_PATH INTEGER NOT NULL,
        NOME_SERVICE_LINE TEXT NOT NULL,
        DESCRICAO TEXT NOT NULL,
        URLIMAGEM TEXT NOT NULL,
        FASE TEXT NOT NULL,
        FOREIGN KEY (ID_LEARNING_PATH) REFERENCES LEARNING_PATHS(ID_LEARNING_PATH)
      )
    ''');

    await db.execute('''
      CREATE TABLE AREA (
        ID_AREA INTEGER PRIMARY KEY,
        ID_SERVICE_LINE INTEGER NOT NULL,
        NOME_AREA TEXT NOT NULL,
        DESCRICAO TEXT NOT NULL,
        URLIMAGEM TEXT NOT NULL,
        FASE TEXT NOT NULL,
        FOREIGN KEY (ID_SERVICE_LINE) REFERENCES SERVICE_LINE(ID_SERVICE_LINE)
      )
    ''');

    await db.execute('''
CREATE TABLE UTILIZADOR (
  ID_UTILIZADOR INTEGER PRIMARY KEY,
  ID_SERVICE_LINE INTEGER,
  ID_AREA INTEGER,
  ID_PERFIL INTEGER NOT NULL,
  NOME_UTILIZADOR TEXT NOT NULL,
  EMAIL TEXT NOT NULL UNIQUE,
  PASSWORD TEXT NOT NULL,
  TELEFONE TEXT NOT NULL,
  PONTUACAOTOTAL INTEGER,
  BADGES_TOTAL INTEGER,
  DATAINGRESSO TEXT NOT NULL,
  ESTADO TEXT NOT NULL,
  PRIMEIRO_LOGIN INTEGER NOT NULL DEFAULT 1,
  URLCERTIFICADO TEXT,
  URLFOTOPERFIL TEXT NOT NULL,
  FOREIGN KEY (ID_SERVICE_LINE) REFERENCES SERVICE_LINE(ID_SERVICE_LINE),
  FOREIGN KEY (ID_AREA) REFERENCES AREA(ID_AREA),
  FOREIGN KEY (ID_PERFIL) REFERENCES PERFIL(ID_PERFIL)
)
''');

    await db.execute('''
      CREATE TABLE BADGE (
        ID_BADGE INTEGER PRIMARY KEY,
        ID_NIVEL INTEGER,
        NOME_BADGE TEXT NOT NULL,
        DESCRICAO TEXT NOT NULL,
        VALIDADE INTEGER,
        DATACRIACAO TEXT NOT NULL,
        URL_IMAGEM TEXT NOT NULL,
        PONTOS INTEGER,
        RARIDADE TEXT NOT NULL,
        URLSITEPUBLICO TEXT,
        URLCERTIFICADO TEXT,
        TIPOBADGE TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE NIVEL (
        ID_NIVEL INTEGER PRIMARY KEY,
        ID_BADGE INTEGER NOT NULL,
        ID_AREA INTEGER NOT NULL,
        NOME_NIVEL TEXT NOT NULL,
        DESCRICAO TEXT NOT NULL,
        URLIMAGEM TEXT NOT NULL,
        FASE TEXT NOT NULL,
        DIFICULDADE TEXT NOT NULL,
        FOREIGN KEY (ID_BADGE) REFERENCES BADGE(ID_BADGE),
        FOREIGN KEY (ID_AREA) REFERENCES AREA(ID_AREA)
      )
    ''');

    await db.execute('''
      CREATE TABLE REQUISITO (
        ID_REQUISITO INTEGER PRIMARY KEY,
        ID_NIVEL INTEGER,
        NOME_REQUISITO TEXT NOT NULL,
        DESCRICAO TEXT NOT NULL,
        TIPOEVIDENCIA TEXT,
        URLIMAGEM TEXT NOT NULL,
        FOREIGN KEY (ID_NIVEL) REFERENCES NIVEL(ID_NIVEL)
      )
    ''');

    await db.execute('''
      CREATE TABLE BADGE_OBTIDO (
        ID_BADGEOBTIDO INTEGER PRIMARY KEY,
        ID_BADGE INTEGER NOT NULL,
        ID_UTILIZADOR INTEGER NOT NULL,
        DATAOBTENCAO TEXT NOT NULL,
        DATAEXPIRACAO TEXT,
        PONTUACAO INTEGER NOT NULL,
        FASE TEXT NOT NULL,
        FOREIGN KEY (ID_BADGE) REFERENCES BADGE(ID_BADGE),
        FOREIGN KEY (ID_UTILIZADOR) REFERENCES UTILIZADOR(ID_UTILIZADOR)
      )
    ''');

    await db.execute('''
      CREATE TABLE CANDIDATURA (
        ID_CANDIDATURA INTEGER PRIMARY KEY,
        ID_UTILIZADOR INTEGER NOT NULL,
        ID_NIVEL INTEGER NOT NULL,
        ID_BADGEOBTIDO INTEGER,
        FASE TEXT NOT NULL,
        DATASUBMISSAO TEXT NOT NULL,
        FOREIGN KEY (ID_UTILIZADOR) REFERENCES UTILIZADOR(ID_UTILIZADOR),
        FOREIGN KEY (ID_NIVEL) REFERENCES NIVEL(ID_NIVEL),
        FOREIGN KEY (ID_BADGEOBTIDO) REFERENCES BADGE_OBTIDO(ID_BADGEOBTIDO)
      )
    ''');

    await db.execute('''
      CREATE TABLE EVIDENCIA (
        ID_EVIDENCIA INTEGER PRIMARY KEY,
        ID_CANDIDATURA INTEGER NOT NULL,
        ID_REQUISITO INTEGER NOT NULL,
        DATA_SUBMISSAO TEXT NOT NULL,
        FASE TEXT,
        FOREIGN KEY (ID_CANDIDATURA) REFERENCES CANDIDATURA(ID_CANDIDATURA),
        FOREIGN KEY (ID_REQUISITO) REFERENCES REQUISITO(ID_REQUISITO)
      )
    ''');

    await db.execute('''
      CREATE TABLE FICHEIROSEVIDENCIA (
        ID_FICHEIROEVIDENCIA INTEGER PRIMARY KEY,
        ID_EVIDENCIA INTEGER,
        NOMEFICHEIRO TEXT NOT NULL,
        URL_FICHEIRO TEXT NOT NULL,
        TAMANHOBYTES INTEGER,
        FOREIGN KEY (ID_EVIDENCIA) REFERENCES EVIDENCIA(ID_EVIDENCIA)
      )
    ''');

    await db.execute('''
      CREATE TABLE VALIDACAOCANDIDATURA (
        ID_VALIDACAO INTEGER PRIMARY KEY,
        ID_CANDIDATURA INTEGER NOT NULL,
        ID_UTILIZADOR INTEGER NOT NULL,
        DATAAVALIACAO TEXT NOT NULL,
        ACAO TEXT NOT NULL,
        COMENTARIO TEXT,
        FASE TEXT NOT NULL,
        FOREIGN KEY (ID_CANDIDATURA) REFERENCES CANDIDATURA(ID_CANDIDATURA),
        FOREIGN KEY (ID_UTILIZADOR) REFERENCES UTILIZADOR(ID_UTILIZADOR)
      )
    ''');

    await db.execute('''
      CREATE TABLE FEEDBACKEVIDENCIA (
        IDFEEDBACK INTEGER PRIMARY KEY,
        ID_EVIDENCIA INTEGER,
        ID_VALIDACAO INTEGER,
        ESTADO TEXT NOT NULL,
        FOREIGN KEY (ID_EVIDENCIA) REFERENCES EVIDENCIA(ID_EVIDENCIA),
        FOREIGN KEY (ID_VALIDACAO) REFERENCES VALIDACAOCANDIDATURA(ID_VALIDACAO)
      )
    ''');

    await db.execute('''
      CREATE TABLE CONFIGURACOES (
        IDCONFIGURACAO INTEGER PRIMARY KEY,
        NOME TEXT NOT NULL,
        VALOR INTEGER NOT NULL,
        DESCRICAO TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ALERTAGLOBAL (
        IDALERTAGLOBAL INTEGER PRIMARY KEY,
        MENSAGEM TEXT NOT NULL,
        DESTINATARIO TEXT NOT NULL,
        DATA TEXT NOT NULL,
        ESTADO TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE RANKING_HISTORICO (
        ID_RANKING INTEGER PRIMARY KEY,
        ID_UTILIZADOR INTEGER NOT NULL,
        TIPO TEXT NOT NULL,
        ANO INTEGER NOT NULL,
        MES INTEGER NOT NULL,
        PONTOSGANHOS INTEGER NOT NULL,
        BADGESGANHOS INTEGER NOT NULL,
        FOREIGN KEY (ID_UTILIZADOR) REFERENCES UTILIZADOR(ID_UTILIZADOR)
      )
    ''');

    await db.execute('''
      CREATE TABLE SUGESTAOMETAS (
        ID_SUGESTAO INTEGER PRIMARY KEY,
        ID_UTILIZADOR INTEGER,
        UTI_ID_UTILIZADOR INTEGER,
        TITULO TEXT NOT NULL,
        DESCRICAO TEXT NOT NULL,
        DATASUGESTAO TEXT NOT NULL,
        DATALIMITE TEXT,
        PONTOS INTEGER NOT NULL,
        ESTADO TEXT NOT NULL,
        URLFICHEIRO TEXT,
        FOREIGN KEY (ID_UTILIZADOR) REFERENCES UTILIZADOR(ID_UTILIZADOR),
        FOREIGN KEY (UTI_ID_UTILIZADOR) REFERENCES UTILIZADOR(ID_UTILIZADOR)
      )
    ''');

    await db.execute('''
      CREATE TABLE NOTIFICACOES (
        ID_NOTIFICACAO INTEGER PRIMARY KEY,
        ID_BADGEOBTIDO INTEGER,
        ID_CANDIDATURA INTEGER,
        ID_UTILIZADOR INTEGER,
        TIPO_NOTIFICACAO TEXT NOT NULL,
        MENSAGEM TEXT,
        DATACRIACAO TEXT NOT NULL,
        FASE TEXT NOT NULL,
        TITULO TEXT NOT NULL,
        FOREIGN KEY (ID_BADGEOBTIDO) REFERENCES BADGE_OBTIDO(ID_BADGEOBTIDO),
        FOREIGN KEY (ID_CANDIDATURA) REFERENCES CANDIDATURA(ID_CANDIDATURA),
        FOREIGN KEY (ID_UTILIZADOR) REFERENCES UTILIZADOR(ID_UTILIZADOR)
      )
    ''');

    await db.execute('''
      CREATE TABLE PARTILHA (
        ID_PARTILHA INTEGER PRIMARY KEY,
        ID_BADGEOBTIDO INTEGER NOT NULL,
        TIPOPARTILHA TEXT NOT NULL,
        DATAPARTILHA TEXT NOT NULL,
        URL_PARTILHA TEXT NOT NULL,
        FOREIGN KEY (ID_BADGEOBTIDO) REFERENCES BADGE_OBTIDO(ID_BADGEOBTIDO)
      )
    ''');

    await db.execute('''
      CREATE TABLE COMPROVATIVO (
        ID_COMPROVATIVO INTEGER PRIMARY KEY,
        ID_BADGEOBTIDO INTEGER NOT NULL,
        TIPOFORMATO TEXT NOT NULL,
        URL_FICHEIRO TEXT NOT NULL,
        DATA_EMISSAO TEXT NOT NULL,
        FOREIGN KEY (ID_BADGEOBTIDO) REFERENCES BADGE_OBTIDO(ID_BADGEOBTIDO)
      )
    ''');

    await db.execute('''
      CREATE TABLE EXPORTACAODADOS (
        ID_EXPORTACAO INTEGER PRIMARY KEY,
        ID_UTILIZADOR INTEGER,
        TIPORELATORIO TEXT NOT NULL,
        FORMATO TEXT NOT NULL,
        DATA TEXT NOT NULL,
        FASE TEXT NOT NULL,
        URL TEXT NOT NULL,
        FOREIGN KEY (ID_UTILIZADOR) REFERENCES UTILIZADOR(ID_UTILIZADOR)
      )
    ''');

    await db.execute('''
      CREATE TABLE TIMELINEEVOLUCAO (
        ID_TIMELINE INTEGER PRIMARY KEY,
        ID_UTILIZADOR INTEGER,
        DATAMODIFICACAO TEXT NOT NULL,
        TITULO TEXT NOT NULL,
        DESCRICAO TEXT NOT NULL,
        URLIMAGEM TEXT,
        FOREIGN KEY (ID_UTILIZADOR) REFERENCES UTILIZADOR(ID_UTILIZADOR)
      )
    ''');
    await DatabaseSeed.seed(db);
  }

  Future<Utilizador?> autenticarUtilizador(
      String email, String password) async {
    final db = await database;
    final result = await db.query(
      'UTILIZADOR',
      where: 'EMAIL = ? AND PASSWORD = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return Utilizador.fromMap(result.first);
    }
    return null;
  }

  Future<int> criarUtilizador(String nome, String email, String password,
      String telefone, int? idArea) async {
    final db = await database;

    final result =
        await db.rawQuery('SELECT MAX(ID_UTILIZADOR) as maxId FROM UTILIZADOR');
    int nextId = (result.first['maxId'] as int? ?? 0) + 1;

    return await db.insert('UTILIZADOR', {
      'ID_UTILIZADOR': nextId,
      'ID_SERVICE_LINE': null,
      'ID_AREA': idArea,
      'ID_PERFIL': 1, // Consultor por padrão
      'NOME_UTILIZADOR': nome,
      'EMAIL': email,
      'PASSWORD': password,
      'TELEFONE': telefone,
      'PONTUACAOTOTAL': 0,
      'BADGES_TOTAL': 0,
      'DATAINGRESSO': DateTime.now().toString().split(' ')[0],
      'ESTADO': 'Inativo',
      'PRIMEIRO_LOGIN': 1,
      'URLCERTIFICADO': null,
      'URLFOTOPERFIL': 'p1.png',
    });
  }

  Future<List<Area>> obterAreas() async {
    final db = await database;
    final result = await db.query('AREA');
    return result.map((map) => Area.fromMap(map)).toList();
  }

  Future<int> ativarUtilizador(String email) async {
    final db = await database;

    return await db.update(
      'UTILIZADOR',
      {'ESTADO': 'Ativo'},
      where: 'EMAIL = ?',
      whereArgs: [email],
    );
  }

  Future<int> alterarPasswordPrimeiroLogin(
    String email,
    String novaPassword,
  ) async {
    final db = await database;

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

  Future<void> atualizarPassword(String email, String novaPassword) async {
    final db = await database;
    await db.update(
      'UTILIZADOR',
      {'PASSWORD': novaPassword},
      where: 'EMAIL = ?',
      whereArgs: [email],
    );
  }

  Future<List<Map<String, dynamic>>> obterBadgesCatalogo(
      {String? areaNome, String? nivelNome}) async {
    final db = await database;

    String query = '''
      SELECT B.ID_BADGE, B.NOME_BADGE as name, B.DESCRICAO as description, 
             B.PONTOS as points, B.RARIDADE as rarity, B.URL_IMAGEM as urlImagem,
             N.ID_NIVEL as idNivel, N.NOME_NIVEL as level, A.NOME_AREA as area
      FROM BADGE B
      LEFT JOIN NIVEL N ON B.ID_BADGE = N.ID_BADGE
      LEFT JOIN AREA A ON N.ID_AREA = A.ID_AREA
    ''';

    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (areaNome != null) {
      whereClauses.add('A.NOME_AREA = ?');
      whereArgs.add(areaNome);
    }

    if (nivelNome != null) {
      whereClauses.add('N.NOME_NIVEL LIKE ?');
      whereArgs.add('%$nivelNome%');
    }

    if (whereClauses.isNotEmpty) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    return await db.rawQuery(query, whereArgs);
  }

  Future<List<Requisito>> obterRequisitosPorNivel(int idNivel) async {
    final db = await database;
    final result = await db.query(
      'REQUISITO',
      where: 'ID_NIVEL = ?',
      whereArgs: [idNivel],
    );
    return result.map((map) => Requisito.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>> obterEstatisticasHome(int idUtilizador) async {
    final db = await database;

    final userRes = await db.query('UTILIZADOR',
        where: 'ID_UTILIZADOR = ?', whereArgs: [idUtilizador]);
    if (userRes.isEmpty) return {};
    final user = userRes.first;

    final badgesRes = await db.rawQuery('''
      SELECT BO.DATAOBTENCAO, B.NOME_BADGE as name, B.URL_IMAGEM as urlImagem, B.PONTOS as points, B.RARIDADE as rarity
      FROM BADGE_OBTIDO BO
      JOIN BADGE B ON BO.ID_BADGE = B.ID_BADGE
      WHERE BO.ID_UTILIZADOR = ?
    ''', [idUtilizador]);

    final candRes = await db.rawQuery('''
      SELECT C.ID_CANDIDATURA as id, C.FASE as status, C.DATASUBMISSAO as date, N.NOME_NIVEL as level, B.NOME_BADGE as name
      FROM CANDIDATURA C
      JOIN NIVEL N ON C.ID_NIVEL = N.ID_NIVEL
      JOIN BADGE B ON N.ID_BADGE = B.ID_BADGE
      WHERE C.ID_UTILIZADOR = ?
    ''', [idUtilizador]);

    int? idArea = user['ID_AREA'] as int?;
    List<Map<String, dynamic>> recBadges = [];
    if (idArea != null) {
      recBadges = await db.rawQuery('''
        SELECT B.ID_BADGE, B.NOME_BADGE as name, B.URL_IMAGEM as urlImagem, 
               N.NOME_NIVEL as level, N.ID_NIVEL as idNivel, B.PONTOS as points, 
               B.RARIDADE as rarity, A.NOME_AREA as area
        FROM BADGE B
        JOIN NIVEL N ON B.ID_BADGE = N.ID_BADGE
        LEFT JOIN AREA A ON N.ID_AREA = A.ID_AREA
        WHERE N.ID_AREA = ? 
          AND NOT EXISTS (
            SELECT 1 FROM BADGE_OBTIDO BO 
            WHERE BO.ID_BADGE = B.ID_BADGE AND BO.ID_UTILIZADOR = ?
          )
          AND NOT EXISTS (
            SELECT 1 FROM CANDIDATURA C
            JOIN NIVEL NV ON C.ID_NIVEL = NV.ID_NIVEL
            WHERE NV.ID_BADGE = B.ID_BADGE AND C.ID_UTILIZADOR = ?
          )
        LIMIT 2
      ''', [idArea, idUtilizador, idUtilizador]);
    }

    final rankingRes = await db.rawQuery('''
      SELECT ID_UTILIZADOR FROM UTILIZADOR ORDER BY COALESCE(PONTUACAOTOTAL, 0) DESC
    ''');
    int rankingPos = 1;
    for (int i = 0; i < rankingRes.length; i++) {
      if (rankingRes[i]['ID_UTILIZADOR'] == idUtilizador) {
        rankingPos = i + 1;
        break;
      }
    }

    final totalCandRes = await db.rawQuery('''
      SELECT 
        COUNT(CASE WHEN FASE = 'Aprovada' THEN 1 END) as approvedCount,
        COUNT(CASE WHEN FASE = 'Rejeitada' THEN 1 END) as rejectedCount
      FROM CANDIDATURA
      WHERE ID_UTILIZADOR = ?
    ''', [idUtilizador]);
    int approved = (totalCandRes.first['approvedCount'] as int?) ?? 0;
    int rejected = (totalCandRes.first['rejectedCount'] as int?) ?? 0;
    int totalResolved = approved + rejected;
    int successRate = totalResolved > 0 ? ((approved / totalResolved) * 100).round() : 0;

    return {
      'pontos': user['PONTUACAOTOTAL'] ?? 0,
      'badgesCount': user['BADGES_TOTAL'] ?? 0,
      'badges': badgesRes,
      'candidaturas': candRes,
      'recomendados': recBadges,
      'rankingPosition': rankingPos,
      'successRate': successRate,
    };
  }

  Future<List<Map<String, dynamic>>> obterRankings() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT U.NOME_UTILIZADOR as nome, U.PONTUACAOTOTAL as pontos, 
             U.BADGES_TOTAL as badges, U.URLFOTOPERFIL as foto,
             P.NOME_PERFIL as perfil
      FROM UTILIZADOR U
      JOIN PERFIL P ON U.ID_PERFIL = P.ID_PERFIL
      ORDER BY U.PONTUACAOTOTAL DESC
    ''');
  }

  Future<int> submeterCandidaturaComEvidencias(
      int idUtilizador, int idNivel, Map<int, String> evidencias) async {
    final db = await database;
    int idCandidatura = 0;

    await db.transaction((txn) async {
      final candRes = await txn
          .rawQuery('SELECT MAX(ID_CANDIDATURA) as maxId FROM CANDIDATURA');
      idCandidatura = (candRes.first['maxId'] as int? ?? 0) + 1;

      await txn.insert('CANDIDATURA', {
        'ID_CANDIDATURA': idCandidatura,
        'ID_UTILIZADOR': idUtilizador,
        'ID_NIVEL': idNivel,
        'ID_BADGEOBTIDO': null,
        'FASE': 'Submetida',
        'DATASUBMISSAO': DateTime.now().toString().split(' ')[0],
      });

      final evidRes = await txn
          .rawQuery('SELECT MAX(ID_EVIDENCIA) as maxId FROM EVIDENCIA');
      int nextEvidId = (evidRes.first['maxId'] as int? ?? 0) + 1;

      for (var entry in evidencias.entries) {
        int idRequisito = entry.key;
        String caminhoEvidencia = entry.value;

        int idEvidencia = nextEvidId++;

        await txn.insert('EVIDENCIA', {
          'ID_EVIDENCIA': idEvidencia,
          'ID_CANDIDATURA': idCandidatura,
          'ID_REQUISITO': idRequisito,
          'DATA_SUBMISSAO': DateTime.now().toString().split(' ')[0],
          'FASE': 'Submetida',
        });

        final fileRes = await txn.rawQuery(
            'SELECT MAX(ID_FICHEIROEVIDENCIA) as maxId FROM FICHEIROSEVIDENCIA');
        int idFicheiro = (fileRes.first['maxId'] as int? ?? 0) + 1;

        await txn.insert('FICHEIROSEVIDENCIA', {
          'ID_FICHEIROEVIDENCIA': idFicheiro,
          'ID_EVIDENCIA': idEvidencia,
          'NOMEFICHEIRO': caminhoEvidencia.split('/').last.split('\\').last,
          'URL_FICHEIRO': caminhoEvidencia,
          'TAMANHOBYTES': 1024,
        });
      }

      final notRes = await txn
          .rawQuery('SELECT MAX(ID_NOTIFICACAO) as maxId FROM NOTIFICACOES');
      int idNotif = (notRes.first['maxId'] as int? ?? 0) + 1;

      final nameRes = await txn.rawQuery('''
        SELECT B.NOME_BADGE, N.NOME_NIVEL 
        FROM NIVEL N 
        JOIN BADGE B ON N.ID_BADGE = B.ID_BADGE 
        WHERE N.ID_NIVEL = ?
      ''', [idNivel]);
      final bName =
          nameRes.isNotEmpty ? nameRes.first['NOME_BADGE'] as String : 'Badge';
      final nName =
          nameRes.isNotEmpty ? nameRes.first['NOME_NIVEL'] as String : 'Nível';

      await txn.insert('NOTIFICACOES', {
        'ID_NOTIFICACAO': idNotif,
        'ID_BADGEOBTIDO': null,
        'ID_CANDIDATURA': idCandidatura,
        'ID_UTILIZADOR': idUtilizador,
        'TIPO_NOTIFICACAO': 'Submissao',
        'MENSAGEM':
            'Submeteste as evidências para a candidatura ao badge "$bName" ($nName).',
        'DATACRIACAO': DateTime.now().toString().split(' ')[0],
        'FASE': 'Nao Lida',
        'TITULO': 'Candidatura Submetida',
      });
    });

    return idCandidatura;
  }

  Future<String> obterNomePerfil(int idPerfil) async {
    final db = await database;
    final res = await db.query('PERFIL',
        columns: ['NOME_PERFIL'],
        where: 'ID_PERFIL = ?',
        whereArgs: [idPerfil]);
    if (res.isNotEmpty) {
      return res.first['NOME_PERFIL'] as String;
    }
    return 'Consultor';
  }

  Future<String> obterNomeServiceLine(int? idServiceLine) async {
    if (idServiceLine == null) return 'N/A';
    final db = await database;
    final res = await db.query('SERVICE_LINE',
        columns: ['NOME_SERVICE_LINE'],
        where: 'ID_SERVICE_LINE = ?',
        whereArgs: [idServiceLine]);
    if (res.isNotEmpty) {
      return res.first['NOME_SERVICE_LINE'] as String;
    }
    return 'N/A';
  }

  Future<String> obterNomeArea(int? idArea) async {
    if (idArea == null) return 'N/A';
    final db = await database;
    final res = await db.query('AREA',
        columns: ['NOME_AREA'], where: 'ID_AREA = ?', whereArgs: [idArea]);
    if (res.isNotEmpty) {
      return res.first['NOME_AREA'] as String;
    }
    return 'N/A';
  }

  Future<void> atualizarDadosPerfil(
      int idUtilizador, String nome, String telefone) async {
    final db = await database;
    await db.update(
      'UTILIZADOR',
      {
        'NOME_UTILIZADOR': nome,
        'TELEFONE': telefone,
      },
      where: 'ID_UTILIZADOR = ?',
      whereArgs: [idUtilizador],
    );

    if (Session.utilizador != null &&
        Session.utilizador!.idUtilizador == idUtilizador) {
      final updatedRes = await db.query('UTILIZADOR',
          where: 'ID_UTILIZADOR = ?', whereArgs: [idUtilizador]);
      if (updatedRes.isNotEmpty) {
        Session.utilizador = Utilizador.fromMap(updatedRes.first);
      }
    }
  }
}

Future<Utilizador?> obterUtilizadorPorEmail(String email) async {
    final db = await database;

    final resultado = await db.query(
      'UTILIZADOR',
      where: 'EMAIL = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Utilizador.fromMap(resultado.first);
  }

class Session {
  static Utilizador? utilizador;
}
