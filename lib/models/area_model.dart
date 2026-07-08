class Area {
  final int idArea;
  final int idServiceLine;
  final String nomeArea;
  final String descricao;
  final String urlImagem;
  final String fase;

  Area({
    required this.idArea,
    required this.idServiceLine,
    required this.nomeArea,
    required this.descricao,
    required this.urlImagem,
    required this.fase,
  });

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      idArea: map['ID_AREA'],
      idServiceLine: map['ID_SERVICE_LINE'],
      nomeArea: map['NOME_AREA'],
      descricao: map['DESCRICAO'],
      urlImagem: map['URLIMAGEM'],
      fase: map['FASE'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_AREA': idArea,
      'ID_SERVICE_LINE': idServiceLine,
      'NOME_AREA': nomeArea,
      'DESCRICAO': descricao,
      'URLIMAGEM': urlImagem,
      'FASE': fase,
    };
  }
}
