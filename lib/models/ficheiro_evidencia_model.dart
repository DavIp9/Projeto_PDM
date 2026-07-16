class FicheiroEvidencia {
  final int idFicheiroEvidencia;
  final int? idEvidencia;
  final String nomeFicheiro;
  final String urlFicheiro;
  final int? tamanhoBytes;

  FicheiroEvidencia({
    required this.idFicheiroEvidencia,
    this.idEvidencia,
    required this.nomeFicheiro,
    required this.urlFicheiro,
    this.tamanhoBytes,
  });

  factory FicheiroEvidencia.fromMap(Map<String, dynamic> map) {
    return FicheiroEvidencia(
      idFicheiroEvidencia: map['ID_FICHEIROEVIDENCIA'],
      idEvidencia: map['ID_EVIDENCIA'],
      nomeFicheiro: map['NOMEFICHEIRO'],
      urlFicheiro: map['URL_FICHEIRO'],
      tamanhoBytes: map['TAMANHOBYTES'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_FICHEIROEVIDENCIA': idFicheiroEvidencia,
        'ID_EVIDENCIA': idEvidencia,
        'NOMEFICHEIRO': nomeFicheiro,
        'URL_FICHEIRO': urlFicheiro,
        'TAMANHOBYTES': tamanhoBytes,
      };
}
