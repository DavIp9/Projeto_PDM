import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/utilizador_model.dart';
import '../models/area_model.dart';
import '../models/requisito_model.dart';
import '../services/email_service.dart';

class FirestoreRepository {
  static final instance = FirestoreRepository._();
  FirestoreRepository._();
  final db = FirebaseFirestore.instance;
  String get uid => FirebaseAuth.instance.currentUser!.uid;
  Future<Utilizador?> obterUtilizadorAtual() async {
    final d = await db.collection('users').doc(uid).get();
    return d.exists ? Utilizador.fromFirestore(d) : null;
  }

  Future<Utilizador?> obterUtilizadorPorEmail(String email) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u != null && u.email == email) return obterUtilizadorAtual();
    final q = await db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return q.docs.isEmpty ? null : Utilizador.fromFirestore(q.docs.first);
  }

  Future<Utilizador?> autenticarUtilizador(String email, String ignored) =>
      obterUtilizadorPorEmail(email);

  int? _obterServiceLinePorArea(int? idArea) {
    switch (idArea) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return null;
    }
  }

  Future<int> criarUtilizador(String nome, String email, String ignored,
      String telefone, int? idArea) async {
    final u = FirebaseAuth.instance.currentUser!;
    await db.collection('users').doc(u.uid).set({
      'legacyId': 0,
      'areaId': idArea,
      'serviceLineId': _obterServiceLinePorArea(idArea),
      'profileId': 1,
      'name': nome,
      'email': email,
      'phone': telefone,
      'totalPoints': 0,
      'totalBadges': 0,
      'joinedAt': DateTime.now().toIso8601String().split('T').first,
      'status': 'Inativo',
      'firstLogin': true,
      'profilePhotoUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    });
    return 1;
  }

  Future<int> ativarUtilizador(String email) async {
    await db.collection('users').doc(uid).update({
      'status': 'Ativo',
      'emailVerified': true,
      'updatedAt': FieldValue.serverTimestamp()
    });
    return 1;
  }

  Future<int> alterarPasswordPrimeiroLogin(String email, String ignored) async {
    await db.collection('users').doc(uid).update(
        {'firstLogin': false, 'updatedAt': FieldValue.serverTimestamp()});
    return 1;
  }

  Future<void> atualizarPassword(String email, String ignored) async {}
  Future<List<Area>> obterAreas() async {
    final q = await db.collection('areas').orderBy('legacyId').get();
    return q.docs
        .map((d) => Area.fromMap({
              'ID_AREA': d.data()['legacyId'] ?? int.tryParse(d.id) ?? 0,
              'ID_SERVICE_LINE': d.data()['serviceLineId'] ?? 0,
              'NOME_AREA': d.data()['name'] ?? '',
              'DESCRICAO': d.data()['description'] ?? '',
              'URLIMAGEM': d.data()['imageUrl'] ?? '',
              'FASE': d.data()['status'] ?? 'Ativo'
            }))
        .toList();
  }

  Future<List<Map<String, dynamic>>> obterBadgesCatalogo(
      {String? areaNome, String? nivelNome}) async {
    final q = await db.collection('badges').get();
    var rows = q.docs
        .map((d) => {
              'id': d.id,
              'ID_BADGE': d.data()['legacyId'] ?? int.tryParse(d.id) ?? 0,
              'name': d.data()['name'],
              'description': d.data()['description'],
              'points': d.data()['points'] ?? 0,
              'rarity': d.data()['rarity'],
              'urlImagem': d.data()['imageUrl'],
              'idNivel': d.data()['levelId'],
              'level': d.data()['levelName'],
              'area': d.data()['areaName']
            })
        .toList();
    if (areaNome != null) {
      if (areaNome == 'Outros') {
        rows = rows
            .where(
                (x) => x['area'] == null || x['area'].toString().trim().isEmpty)
            .toList();
      } else {
        rows = rows.where((x) => x['area'] == areaNome).toList();
      }
    }
    if (nivelNome != null) {
      if (nivelNome == 'Especial') {
        rows = rows
            .where((x) =>
                (x['level'] ?? '').toString().contains('Especial') ||
                x['rarity'] == 'Especial')
            .toList();
      } else {
        rows = rows
            .where((x) => (x['level'] ?? '').toString().contains(nivelNome))
            .toList();
      }
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> obterBadgesConquistados() async {
    final earnedSnap = await db
        .collection('earnedBadges')
        .where('userId', isEqualTo: uid)
        .get();

    final List<Map<String, dynamic>> badgesList = [];
    for (final doc in earnedSnap.docs) {
      final earnedData = doc.data();
      final badgeId = earnedData['badgeId'];
      if (badgeId != null) {
        final badgeDoc =
            await db.collection('badges').doc(badgeId.toString()).get();
        if (badgeDoc.exists) {
          final badgeData = badgeDoc.data()!;
          badgesList.add({
            'id': badgeDoc.id,
            'ID_BADGE': badgeData['legacyId'] ?? int.tryParse(badgeDoc.id) ?? 0,
            'name': badgeData['name'],
            'description': badgeData['description'],
            'points': badgeData['points'] ?? 0,
            'rarity': badgeData['rarity'],
            'urlImagem': badgeData['imageUrl'],
            'idNivel': badgeData['levelId'],
            'level': badgeData['levelName'],
            'area': badgeData['areaName'],
            'obtainedAt': earnedData['obtainedAt'],
          });
        } else {
          badgesList.add({
            'ID_BADGE': int.tryParse(badgeId.toString()) ?? 0,
            'name': earnedData['badgeName'] ?? 'Badge',
            'points': earnedData['points'] ?? 0,
            'obtainedAt': earnedData['obtainedAt'],
          });
        }
      }
    }
    return badgesList;
  }

  Future<List<Requisito>> obterRequisitosPorNivel(int idNivel) async {
    final q = await db
        .collection('requirements')
        .where('levelId', isEqualTo: idNivel)
        .get();
    return q.docs
        .map((d) => Requisito.fromMap({
              'ID_REQUISITO': d.data()['legacyId'] ?? int.tryParse(d.id) ?? 0,
              'ID_NIVEL': d.data()['levelId'],
              'NOME_REQUISITO': d.data()['name'] ?? '',
              'DESCRICAO': d.data()['description'] ?? '',
              'TIPOEVIDENCIA': d.data()['evidenceType'],
              'URLIMAGEM': d.data()['imageUrl'] ?? ''
            }))
        .toList();
  }

  Future<Map<String, dynamic>> obterEstatisticasHome(int ignored) async {
    final u = await obterUtilizadorAtual();

    if (u == null) return {};

    final earned = await db
        .collection('earnedBadges')
        .where('userId', isEqualTo: uid)
        .get();

    final apps = await db
        .collection('applications')
        .where('userId', isEqualTo: uid)
        .get();

    final rec = await obterBadgesCatalogo();

    final areaNome = u.idArea != null ? await obterNomeArea(u.idArea) : null;
    final earnedBadgeIds = earned.docs
        .map((d) => d.data()['badgeId']?.toString())
        .where((id) => id != null)
        .toSet();

    var filteredRec = rec.where((badge) {
      final badgeId = badge['id'];
      final matchesArea = areaNome == null || badge['area'] == areaNome;
      return !earnedBadgeIds.contains(badgeId) && matchesArea;
    }).toList();

    if (filteredRec.isEmpty) {
      filteredRec = rec.where((badge) {
        final badgeId = badge['id'];
        return !earnedBadgeIds.contains(badgeId);
      }).toList();
    }

    final totalCandidaturas = apps.docs.length;

    final candidaturasAprovadas = apps.docs.where((d) {
      return d.data()['status'] == 'Aprovada';
    }).length;

    final taxaSucesso = totalCandidaturas == 0
        ? 0
        : ((candidaturasAprovadas / totalCandidaturas) * 100).round();

    final rankingSnapshot = await db
        .collection('users')
        .orderBy('totalPoints', descending: true)
        .get();

    int rankingPosition = 0;

    for (int i = 0; i < rankingSnapshot.docs.length; i++) {
      if (rankingSnapshot.docs[i].id == uid) {
        rankingPosition = i + 1;
        break;
      }
    }

    return {
      'pontos': u.pontuacaoTotal,
      'badgesCount': u.badgesTotal,
      'rankingPosition': rankingPosition,
      'successRate': taxaSucesso,
      'badges': earned.docs.map((d) => d.data()).toList(),
      'candidaturas': apps.docs
          .map((d) => {
                'id': d.id,
                ...d.data(),
              })
          .toList(),
      'recomendados': filteredRec.take(2).toList(),
    };
  }

  Future<List<Map<String, dynamic>>> obterRankings() async {
    final q = await db
        .collection('users')
        .orderBy('totalPoints', descending: true)
        .get();
    return q.docs
        .map((d) => {
              'nome': d.data()['name'] ?? '',
              'pontos': d.data()['totalPoints'] ?? 0,
              'badges': d.data()['totalBadges'] ?? 0,
              'foto': d.data()['profilePhotoUrl'],
              'perfil': d.data()['profileName'] ?? 'Consultor'
            })
        .toList();
  }

  Future<String> submeterCandidaturaComEvidencias(
    int ignored,
    int idNivel,
    Map<int, String> evidencias,
  ) async {
    final user = Session.utilizador ?? await obterUtilizadorAtual();

    if (user == null) {
      throw Exception('Utilizador não encontrado.');
    }

    if (evidencias.isEmpty) {
      throw Exception('Seleciona pelo menos uma evidência.');
    }

    final badgeQ = await db
        .collection('badges')
        .where('levelId', isEqualTo: idNivel)
        .limit(1)
        .get();

    final badge =
        badgeQ.docs.isEmpty ? <String, dynamic>{} : badgeQ.docs.first.data();

    final badgeName = badge['name']?.toString() ?? 'Badge';
    final levelName = badge['levelName']?.toString() ?? 'Nível';

    final ref = db.collection('applications').doc();

    await ref.set({
      'userId': uid,
      'userName': user.nomeUtilizador,
      'levelId': idNivel,
      'levelName': levelName,
      'badgeId': badgeQ.docs.isEmpty ? null : badgeQ.docs.first.id,
      'badgeName': badgeName,
      'badgePoints': badge['points'] ?? 0,
      'validityDays': (badge['validityDays'] as num?)?.toInt() ?? 365,
      'status': 'Submetida',
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    for (final evidencia in evidencias.entries) {
      final caminhoLocal = evidencia.value;
      final nomeFicheiro = caminhoLocal.split(RegExp(r'[/\\]')).last;

      await ref.collection('evidences').add({
        'requirementId': evidencia.key,
        'userId': uid,
        'fileName': nomeFicheiro,
        'localPath': caminhoLocal,
        'status': 'Submetida',
        'submittedAt': FieldValue.serverTimestamp(),
      });
    }

    // Notificação dentro da aplicação.
    await db.collection('notifications').add({
      'userId': uid,
      'applicationId': ref.id,
      'title': 'Candidatura Submetida',
      'message': 'A tua candidatura ao badge "$badgeName", nível "$levelName", '
          'foi submetida com sucesso.',
      'type': 'Submissao',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notificação por email.
    final emailAtual = FirebaseAuth.instance.currentUser?.email;

    if (emailAtual != null && emailAtual.trim().isNotEmpty) {
      try {
        await EmailService.instance.enviarCandidaturaSubmetida(
          nome: user.nomeUtilizador,
          email: emailAtual.trim(),
          badge: badgeName,
          nivel: levelName,
        );
      } catch (e) {}
    }

    return ref.id;
  }

  Future<String> obterNomePerfil(int id) async {
    final d = await db.collection('profiles').doc('$id').get();
    return d.data()?['name'] ?? 'Consultor';
  }

  Future<String> obterNomeServiceLine(int? id) async {
    if (id == null) return 'N/A';
    final d = await db.collection('serviceLines').doc('$id').get();
    return d.data()?['name'] ?? 'N/A';
  }

  Future<String> obterNomeArea(int? id) async {
    if (id == null) return 'N/A';
    final d = await db.collection('areas').doc('$id').get();
    return d.data()?['name'] ?? 'N/A';
  }

  Future<void> atualizarDadosPerfil(
      int ignored, String nome, String telefone) async {
    await db.collection('users').doc(uid).update({
      'name': nome,
      'phone': telefone,
      'updatedAt': FieldValue.serverTimestamp()
    });
    await FirebaseAuth.instance.currentUser?.updateDisplayName(nome);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> notifications() => db
      .collection('notifications')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> applications(bool evaluator) =>
      evaluator
          ? db
              .collection('applications')
              .orderBy('submittedAt', descending: true)
              .snapshots()
          : db
              .collection('applications')
              .where('userId', isEqualTo: uid)
              .orderBy('submittedAt', descending: true)
              .snapshots();
  Future<void> markNotification(String id, bool read) =>
      db.collection('notifications').doc(id).update({'read': read});

  Future<void> deleteNotification(String id) =>
      db.collection('notifications').doc(id).delete();

  Future<void> evaluateApplication(
      String id, bool approved, String comment) async {
    final ref = db.collection('applications').doc(id);
    await db.runTransaction((t) async {
      final snap = await t.get(ref);
      if (!snap.exists) return;
      final a = snap.data()!;
      if (!['Submetida', 'Em Correcao'].contains(a['status'])) return;
      final status = approved ? 'Aprovada' : 'Rejeitada';
      t.update(ref, {
        'status': status,
        'evaluatedAt': FieldValue.serverTimestamp(),
        'evaluationComment': comment,
        'evaluatorId': uid
      });
      if (approved) {
        final userRef = db.collection('users').doc(a['userId']);

        final validityDays = (a['validityDays'] as num?)?.toInt() ?? 365;

        final obtainedAt = DateTime.now();

        final expiresAt = obtainedAt.add(
          Duration(days: validityDays),
        );

        t.set(db.collection('earnedBadges').doc(), {
          'userId': a['userId'],
          'badgeId': a['badgeId'],
          'badgeName': a['badgeName'],
          'points': a['badgePoints'] ?? 0,
          'validityDays': validityDays,
          'obtainedAt': Timestamp.fromDate(obtainedAt),
          'expiresAt': Timestamp.fromDate(expiresAt),
          'status': 'Ativo',
          'applicationId': id,
        });

        t.update(userRef, {
          'totalPoints': FieldValue.increment(
            a['badgePoints'] ?? 0,
          ),
          'totalBadges': FieldValue.increment(1),
        });
      }
      t.set(db.collection('notifications').doc(), {
        'userId': a['userId'],
        'applicationId': id,
        'title': 'Candidatura $status',
        'message': comment,
        'type': 'Avaliacao',
        'read': false,
        'createdAt': FieldValue.serverTimestamp()
      });
    });
  }

  Future<void> verificarExpiracaoBadges() async {
    final resultado = await db
        .collection('earnedBadges')
        .where('userId', isEqualTo: uid)
        .get();

    const diasParaAvisar = {30, 15, 7, 2, 1};

    final agora = DateTime.now();

    final hoje = DateTime(
      agora.year,
      agora.month,
      agora.day,
    );

    for (final documento in resultado.docs) {
      final badge = documento.data();

      final expiresAtValue = badge['expiresAt'];

      if (expiresAtValue is! Timestamp) {
        continue;
      }

      final dataExpiracaoOriginal = expiresAtValue.toDate();

      final dataExpiracao = DateTime(
        dataExpiracaoOriginal.year,
        dataExpiracaoOriginal.month,
        dataExpiracaoOriginal.day,
      );

      final diasRestantes = dataExpiracao.difference(hoje).inDays;

      if (diasRestantes <= 0) {
        await documento.reference.update({
          'status': 'Expirado',
        });

        continue;
      }

      if (!diasParaAvisar.contains(diasRestantes)) {
        continue;
      }

      final notificationId = 'badge_expiration_${documento.id}_$diasRestantes';

      final notificationRef =
          db.collection('notifications').doc(notificationId);

      final notificationSnapshot = await notificationRef.get();

      if (notificationSnapshot.exists) {
        continue;
      }

      final badgeName = badge['badgeName']?.toString() ?? 'Badge';

      await notificationRef.set({
        'userId': uid,
        'earnedBadgeId': documento.id,
        'badgeId': badge['badgeId'],
        'title': 'Badge perto de expirar',
        'message': diasRestantes == 1
            ? 'O badge "$badgeName" expira amanhã.'
            : 'O badge "$badgeName" expira dentro de '
                '$diasRestantes dias.',
        'type': 'ExpiracaoBadge',
        'daysRemaining': diasRestantes,
        'expiresAt': expiresAtValue,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> eliminarContaEDados() async {
    final authUser = FirebaseAuth.instance.currentUser;

    if (authUser == null) {
      throw Exception('Não existe utilizador autenticado.');
    }

    final userId = authUser.uid;

    // 1. Apagar candidaturas e respetivas evidências.
    final candidaturas = await db
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .get();

    for (final candidatura in candidaturas.docs) {
      final evidencias =
          await candidatura.reference.collection('evidences').get();

      for (final evidencia in evidencias.docs) {
        await evidencia.reference.delete();
      }

      await candidatura.reference.delete();
    }

    // 2. Apagar notificações.
    final notificacoes = await db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (final notificacao in notificacoes.docs) {
      await notificacao.reference.delete();
    }

    // 3. Apagar badges conquistados.
    final badgesObtidos = await db
        .collection('earnedBadges')
        .where('userId', isEqualTo: userId)
        .get();

    for (final badge in badgesObtidos.docs) {
      await badge.reference.delete();
    }

    // 4. Apagar configurações, caso existam como subcoleção.
    final configuracoes =
        await db.collection('users').doc(userId).collection('settings').get();

    for (final configuracao in configuracoes.docs) {
      await configuracao.reference.delete();
    }

    // 5. Apagar documento principal do utilizador.
    await db.collection('users').doc(userId).delete();

    // 6. Apagar conta do Firebase Authentication.
    await authUser.delete();

    Session.utilizador = null;
  }
}
