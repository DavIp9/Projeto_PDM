class ValidacaoCandidatura {
  final int idValidacao;
  final int idCandidatura;
  final int idUtilizador;
  final String dataAvaliacao;
  final String acao;
  final String? comentario;
  final String fase;

  ValidacaoCandidatura({
    required this.idValidacao,
    required this.idCandidatura,
    required this.idUtilizador,
    required this.dataAvaliacao,
    required this.acao,
    this.comentario,
    required this.fase,
  });

  factory ValidacaoCandidatura.fromMap(Map<String, dynamic> map) {
    return ValidacaoCandidatura(
      idValidacao: map['ID_VALIDACAO'],
      idCandidatura: map['ID_CANDIDATURA'],
      idUtilizador: map['ID_UTILIZADOR'],
      dataAvaliacao: map['DATAAVALIACAO'],
      acao: map['ACAO'],
      comentario: map['COMENTARIO'],
      fase: map['FASE'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_VALIDACAO': idValidacao,
        'ID_CANDIDATURA': idCandidatura,
        'ID_UTILIZADOR': idUtilizador,
        'DATAAVALIACAO': dataAvaliacao,
        'ACAO': acao,
        'COMENTARIO': comentario,
        'FASE': fase,
      };
}
