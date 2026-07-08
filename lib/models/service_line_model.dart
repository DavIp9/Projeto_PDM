class ServiceLine {
  final int idServiceLine;
  final int idLearningPath;
  final String nomeServiceLine;
  final String descricao;
  final String urlImagem;
  final String fase;

  ServiceLine({
    required this.idServiceLine,
    required this.idLearningPath,
    required this.nomeServiceLine,
    required this.descricao,
    required this.urlImagem,
    required this.fase,
  });

  factory ServiceLine.fromMap(Map<String, dynamic> map) {
    return ServiceLine(
      idServiceLine: map['ID_SERVICE_LINE'],
      idLearningPath: map['ID_LEARNING_PATH'],
      nomeServiceLine: map['NOME_SERVICE_LINE'],
      descricao: map['DESCRICAO'],
      urlImagem: map['URLIMAGEM'],
      fase: map['FASE'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_SERVICE_LINE': idServiceLine,
      'ID_LEARNING_PATH': idLearningPath,
      'NOME_SERVICE_LINE': nomeServiceLine,
      'DESCRICAO': descricao,
      'URLIMAGEM': urlImagem,
      'FASE': fase,
    };
  }
}
