class ExportacaoDados {
  final int idExportacao;
  final int? idUtilizador;
  final String tipoRelatorio;
  final String formato;
  final String data;
  final String fase;
  final String url;

  ExportacaoDados({
    required this.idExportacao,
    this.idUtilizador,
    required this.tipoRelatorio,
    required this.formato,
    required this.data,
    required this.fase,
    required this.url,
  });

  factory ExportacaoDados.fromMap(Map<String, dynamic> map) {
    return ExportacaoDados(
      idExportacao: map['ID_EXPORTACAO'],
      idUtilizador: map['ID_UTILIZADOR'],
      tipoRelatorio: map['TIPORELATORIO'],
      formato: map['FORMATO'],
      data: map['DATA'],
      fase: map['FASE'],
      url: map['URL'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_EXPORTACAO': idExportacao,
        'ID_UTILIZADOR': idUtilizador,
        'TIPORELATORIO': tipoRelatorio,
        'FORMATO': formato,
        'DATA': data,
        'FASE': fase,
        'URL': url,
      };
}
