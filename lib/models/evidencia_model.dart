class Evidencia {
  final int idEvidencia;
  final int idCandidatura;
  final int idRequisito;
  final String dataSubmissao;
  final String? fase;

  Evidencia({
    required this.idEvidencia,
    required this.idCandidatura,
    required this.idRequisito,
    required this.dataSubmissao,
    this.fase,
  });

  factory Evidencia.fromMap(Map<String, dynamic> map) {
    return Evidencia(
      idEvidencia: map['ID_EVIDENCIA'],
      idCandidatura: map['ID_CANDIDATURA'],
      idRequisito: map['ID_REQUISITO'],
      dataSubmissao: map['DATA_SUBMISSAO'],
      fase: map['FASE'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_EVIDENCIA': idEvidencia,
        'ID_CANDIDATURA': idCandidatura,
        'ID_REQUISITO': idRequisito,
        'DATA_SUBMISSAO': dataSubmissao,
        'FASE': fase,
      };
}
