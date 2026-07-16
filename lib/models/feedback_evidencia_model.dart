class FeedbackEvidencia {
  final int idFeedback;
  final int? idEvidencia;
  final int? idValidacao;
  final String estado;

  FeedbackEvidencia({
    required this.idFeedback,
    this.idEvidencia,
    this.idValidacao,
    required this.estado,
  });

  factory FeedbackEvidencia.fromMap(Map<String, dynamic> map) {
    return FeedbackEvidencia(
      idFeedback: map['IDFEEDBACK'],
      idEvidencia: map['ID_EVIDENCIA'],
      idValidacao: map['ID_VALIDACAO'],
      estado: map['ESTADO'],
    );
  }

  Map<String, dynamic> toMap() => {
        'IDFEEDBACK': idFeedback,
        'ID_EVIDENCIA': idEvidencia,
        'ID_VALIDACAO': idValidacao,
        'ESTADO': estado,
      };
}
