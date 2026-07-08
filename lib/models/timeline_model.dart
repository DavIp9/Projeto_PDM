class Timeline {
  final int idTimeline;
  final int? idUtilizador;
  final String dataModificacao;
  final String titulo;
  final String descricao;
  final String? urlImagem;

  Timeline({
    required this.idTimeline,
    this.idUtilizador,
    required this.dataModificacao,
    required this.titulo,
    required this.descricao,
    this.urlImagem,
  });

  factory Timeline.fromMap(Map<String, dynamic> map) {
    return Timeline(
      idTimeline: map['ID_TIMELINE'],
      idUtilizador: map['ID_UTILIZADOR'],
      dataModificacao: map['DATAMODIFICACAO'],
      titulo: map['TITULO'],
      descricao: map['DESCRICAO'],
      urlImagem: map['URLIMAGEM'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_TIMELINE': idTimeline,
        'ID_UTILIZADOR': idUtilizador,
        'DATAMODIFICACAO': dataModificacao,
        'TITULO': titulo,
        'DESCRICAO': descricao,
        'URLIMAGEM': urlImagem,
      };
}
