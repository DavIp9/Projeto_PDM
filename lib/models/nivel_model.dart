class Nivel {
  final int idNivel;
  final int idBadge;
  final int idArea;
  final String nomeNivel;
  final String descricao;
  final String urlImagem;
  final String fase;
  final String dificuldade;

  Nivel({
    required this.idNivel,
    required this.idBadge,
    required this.idArea,
    required this.nomeNivel,
    required this.descricao,
    required this.urlImagem,
    required this.fase,
    required this.dificuldade,
  });

  factory Nivel.fromMap(Map<String, dynamic> map) {
    return Nivel(
      idNivel: map['ID_NIVEL'],
      idBadge: map['ID_BADGE'],
      idArea: map['ID_AREA'],
      nomeNivel: map['NOME_NIVEL'],
      descricao: map['DESCRICAO'],
      urlImagem: map['URLIMAGEM'],
      fase: map['FASE'],
      dificuldade: map['DIFICULDADE'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_NIVEL': idNivel,
      'ID_BADGE': idBadge,
      'ID_AREA': idArea,
      'NOME_NIVEL': nomeNivel,
      'DESCRICAO': descricao,
      'URLIMAGEM': urlImagem,
      'FASE': fase,
      'DIFICULDADE': dificuldade,
    };
  }
}
