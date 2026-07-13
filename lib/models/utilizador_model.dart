class Utilizador {
  final int idUtilizador;
  final int? idServiceLine;
  final int? idArea;
  final int idPerfil;

  final String nomeUtilizador;
  final String email;
  final String password;
  final String telefone;

  final int pontuacaoTotal;
  final int badgesTotal;

  final String dataIngresso;
  final String estado;

  final String? urlCertificado;
  final String? urlFotoPerfil;

  Utilizador({
    required this.idUtilizador,
    this.idServiceLine,
    this.idArea,
    required this.idPerfil,
    required this.nomeUtilizador,
    required this.email,
    required this.password,
    required this.telefone,
    required this.pontuacaoTotal,
    required this.badgesTotal,
    required this.dataIngresso,
    required this.estado,
    this.urlCertificado,
    this.urlFotoPerfil,
  });

  factory Utilizador.fromMap(
    Map<String, dynamic> map,
  ) {
    return Utilizador(
      idUtilizador: map['ID_UTILIZADOR'],
      idServiceLine: map['ID_SERVICE_LINE'],
      idArea: map['ID_AREA'],
      idPerfil: map['ID_PERFIL'],
      nomeUtilizador: map['NOME_UTILIZADOR'],
      email: map['EMAIL'],
      password: map['PASSWORD'],
      telefone: map['TELEFONE'],
      pontuacaoTotal: map['PONTUACAOTOTAL'],
      badgesTotal: map['BADGES_TOTAL'],
      dataIngresso: map['DATAINGRESSO'],
      estado: map['ESTADO'],
      urlCertificado: map['URLCERTIFICADO'],
      urlFotoPerfil: map['URLFOTOPERFIL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_UTILIZADOR': idUtilizador,
      'ID_SERVICE_LINE': idServiceLine,
      'ID_AREA': idArea,
      'ID_PERFIL': idPerfil,
      'NOME_UTILIZADOR': nomeUtilizador,
      'EMAIL': email,
      'PASSWORD': password,
      'TELEFONE': telefone,
      'PONTUACAOTOTAL': pontuacaoTotal,
      'BADGES_TOTAL': badgesTotal,
      'DATAINGRESSO': dataIngresso,
      'ESTADO': estado,
      'URLCERTIFICADO': urlCertificado,
      'URLFOTOPERFIL': urlFotoPerfil,
    };
  }
}
