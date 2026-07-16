class Badge {
  final int idBadge;
  final int? idNivel;

  final String nomeBadge;
  final String descricao;
  final int? validade;
  final String dataCriacao;

  final String urlImagem;

  final int pontos;

  final String raridade;
  final String tipoBadge;

  Badge({
    required this.idBadge,
    this.idNivel,
    required this.nomeBadge,
    required this.descricao,
    this.validade,
    required this.dataCriacao,
    required this.urlImagem,
    required this.pontos,
    required this.raridade,
    required this.tipoBadge,
  });

  factory Badge.fromMap(
    Map<String, dynamic> map,
  ) {
    return Badge(
      idBadge: map['ID_BADGE'],
      idNivel: map['ID_NIVEL'],
      nomeBadge: map['NOME_BADGE'],
      descricao: map['DESCRICAO'],
      validade: map['VALIDADE'],
      dataCriacao: map['DATACRIACAO'],
      urlImagem: map['URL_IMAGEM'],
      pontos: map['PONTOS'],
      raridade: map['RARIDADE'],
      tipoBadge: map['TIPOBADGE'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_BADGE': idBadge,
      'ID_NIVEL': idNivel,
      'NOME_BADGE': nomeBadge,
      'DESCRICAO': descricao,
      'VALIDADE': validade,
      'DATACRIACAO': dataCriacao,
      'URL_IMAGEM': urlImagem,
      'PONTOS': pontos,
      'RARIDADE': raridade,
      'TIPOBADGE': tipoBadge,
    };
  }
}
