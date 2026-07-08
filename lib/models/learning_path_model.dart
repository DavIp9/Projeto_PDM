class LearningPath {
  final int idLearningPath;
  final String nomeLearningPath;
  final String descricao;
  final String urlImagem;
  final String fase;

  LearningPath({
    required this.idLearningPath,
    required this.nomeLearningPath,
    required this.descricao,
    required this.urlImagem,
    required this.fase,
  });

  factory LearningPath.fromMap(Map<String, dynamic> map) {
    return LearningPath(
      idLearningPath: map['ID_LEARNING_PATH'],
      nomeLearningPath: map['NOME_LEARNINGPATH'],
      descricao: map['DESCRICAO'],
      urlImagem: map['URLIMAGEM'],
      fase: map['FASE'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_LEARNING_PATH': idLearningPath,
      'NOME_LEARNINGPATH': nomeLearningPath,
      'DESCRICAO': descricao,
      'URLIMAGEM': urlImagem,
      'FASE': fase,
    };
  }
}
