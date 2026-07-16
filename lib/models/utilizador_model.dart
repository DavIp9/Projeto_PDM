import 'package:cloud_firestore/cloud_firestore.dart';

class Utilizador {
  final String uid;
  final int idUtilizador;
  final int? idServiceLine;
  final int? idArea;
  final int idPerfil;
  final String nomeUtilizador;
  final String email;
  final String telefone;
  final int pontuacaoTotal;
  final int badgesTotal;
  final String dataIngresso;
  final String estado;
  final int primeiroLogin;
  final String? urlCertificado;
  final String? urlFotoPerfil;

  const Utilizador({required this.uid, required this.idUtilizador, this.idServiceLine, this.idArea,
    required this.idPerfil, required this.nomeUtilizador, required this.email, required this.telefone,
    required this.pontuacaoTotal, required this.badgesTotal, required this.dataIngresso,
    required this.estado, required this.primeiroLogin, this.urlCertificado, this.urlFotoPerfil});

  factory Utilizador.fromFirestore(DocumentSnapshot<Map<String,dynamic>> doc) => Utilizador.fromMap({...?doc.data(), 'uid': doc.id});
  factory Utilizador.fromMap(Map<String,dynamic> m) => Utilizador(
    uid: (m['uid'] ?? m['UID'] ?? '').toString(), idUtilizador: (m['ID_UTILIZADOR'] ?? m['legacyId'] ?? 0) as int,
    idServiceLine: m['ID_SERVICE_LINE'] ?? m['serviceLineId'], idArea: m['ID_AREA'] ?? m['areaId'],
    idPerfil: (m['ID_PERFIL'] ?? m['profileId'] ?? 1) as int,
    nomeUtilizador: (m['NOME_UTILIZADOR'] ?? m['name'] ?? '').toString(), email: (m['EMAIL'] ?? m['email'] ?? '').toString(),
    telefone: (m['TELEFONE'] ?? m['phone'] ?? '').toString(), pontuacaoTotal: (m['PONTUACAOTOTAL'] ?? m['totalPoints'] ?? 0) as int,
    badgesTotal: (m['BADGES_TOTAL'] ?? m['totalBadges'] ?? 0) as int,
    dataIngresso: (m['DATAINGRESSO'] ?? m['joinedAt'] ?? '').toString(), estado: (m['ESTADO'] ?? m['status'] ?? 'Ativo').toString(),
    primeiroLogin: (m['PRIMEIRO_LOGIN'] ?? m['firstLogin'] ?? 0) is bool ? ((m['PRIMEIRO_LOGIN'] ?? m['firstLogin']) ? 1:0) : (m['PRIMEIRO_LOGIN'] ?? m['firstLogin'] ?? 0) as int,
    urlCertificado: m['URLCERTIFICADO'] ?? m['certificateUrl'], urlFotoPerfil: m['URLFOTOPERFIL'] ?? m['profilePhotoUrl']);
  Map<String,dynamic> toFirestore() => {'legacyId':idUtilizador,'serviceLineId':idServiceLine,'areaId':idArea,'profileId':idPerfil,
    'name':nomeUtilizador,'email':email,'phone':telefone,'totalPoints':pontuacaoTotal,'totalBadges':badgesTotal,
    'joinedAt':dataIngresso,'status':estado,'firstLogin':primeiroLogin==1,'certificateUrl':urlCertificado,'profilePhotoUrl':urlFotoPerfil,
    'updatedAt':FieldValue.serverTimestamp()};
}
class Session { static Utilizador? utilizador; }
