class Requisito {
  final int idRequisito;
  final int? idNivel;
  final String nomeRequisito;
  final String descricao;
  final String? tipoEvidencia;
  final String urlImagem;

  Requisito({
    required this.idRequisito,
    this.idNivel,
    required this.nomeRequisito,
    required this.descricao,
    this.tipoEvidencia,
    required this.urlImagem,
  });

  factory Requisito.fromMap(Map<String, dynamic> map) {
    return Requisito(
      idRequisito: map['ID_REQUISITO'],
      idNivel: map['ID_NIVEL'],
      nomeRequisito: map['NOME_REQUISITO'],
      descricao: map['DESCRICAO'],
      tipoEvidencia: map['TIPOEVIDENCIA'],
      urlImagem: map['URLIMAGEM'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_REQUISITO': idRequisito,
      'ID_NIVEL': idNivel,
      'NOME_REQUISITO': nomeRequisito,
      'DESCRICAO': descricao,
      'TIPOEVIDENCIA': tipoEvidencia,
      'URLIMAGEM': urlImagem,
    };
  }
}
