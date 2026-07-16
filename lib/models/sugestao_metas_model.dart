class SugestaoMetas {
  final int idSugestao;
  final int? idUtilizador;
  final int? utiIdUtilizador;
  final String titulo;
  final String descricao;
  final String dataSugestao;
  final String? dataLimite;
  final int pontos;
  final String estado;
  final String? urlFicheiro;

  SugestaoMetas({
    required this.idSugestao,
    this.idUtilizador,
    this.utiIdUtilizador,
    required this.titulo,
    required this.descricao,
    required this.dataSugestao,
    this.dataLimite,
    required this.pontos,
    required this.estado,
    this.urlFicheiro,
  });

  factory SugestaoMetas.fromMap(Map<String, dynamic> map) {
    return SugestaoMetas(
      idSugestao: map['ID_SUGESTAO'],
      idUtilizador: map['ID_UTILIZADOR'],
      utiIdUtilizador: map['UTI_ID_UTILIZADOR'],
      titulo: map['TITULO'],
      descricao: map['DESCRICAO'],
      dataSugestao: map['DATASUGESTAO'],
      dataLimite: map['DATALIMITE'],
      pontos: map['PONTOS'],
      estado: map['ESTADO'],
      urlFicheiro: map['URLFICHEIRO'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_SUGESTAO': idSugestao,
        'ID_UTILIZADOR': idUtilizador,
        'UTI_ID_UTILIZADOR': utiIdUtilizador,
        'TITULO': titulo,
        'DESCRICAO': descricao,
        'DATASUGESTAO': dataSugestao,
        'DATALIMITE': dataLimite,
        'PONTOS': pontos,
        'ESTADO': estado,
        'URLFICHEIRO': urlFicheiro,
      };
}
