class Candidatura {
  final int idCandidatura;
  final int idUtilizador;
  final int idNivel;
  final int? idBadgeObtido;
  final String fase;
  final String dataSubmissao;

  Candidatura({
    required this.idCandidatura,
    required this.idUtilizador,
    required this.idNivel,
    this.idBadgeObtido,
    required this.fase,
    required this.dataSubmissao,
  });

  factory Candidatura.fromMap(Map<String, dynamic> map) {
    return Candidatura(
      idCandidatura: map['ID_CANDIDATURA'],
      idUtilizador: map['ID_UTILIZADOR'],
      idNivel: map['ID_NIVEL'],
      idBadgeObtido: map['ID_BADGEOBTIDO'],
      fase: map['FASE'],
      dataSubmissao: map['DATASUBMISSAO'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_CANDIDATURA': idCandidatura,
      'ID_UTILIZADOR': idUtilizador,
      'ID_NIVEL': idNivel,
      'ID_BADGEOBTIDO': idBadgeObtido,
      'FASE': fase,
      'DATASUBMISSAO': dataSubmissao,
    };
  }
}
