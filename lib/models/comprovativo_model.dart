class Comprovativo {
  final int idComprovativo;
  final int idBadgeObtido;
  final String tipoFormato;
  final String urlFicheiro;
  final String dataEmissao;

  Comprovativo({
    required this.idComprovativo,
    required this.idBadgeObtido,
    required this.tipoFormato,
    required this.urlFicheiro,
    required this.dataEmissao,
  });

  factory Comprovativo.fromMap(Map<String, dynamic> map) {
    return Comprovativo(
      idComprovativo: map['ID_COMPROVATIVO'],
      idBadgeObtido: map['ID_BADGEOBTIDO'],
      tipoFormato: map['TIPOFORMATO'],
      urlFicheiro: map['URL_FICHEIRO'],
      dataEmissao: map['DATA_EMISSAO'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_COMPROVATIVO': idComprovativo,
        'ID_BADGEOBTIDO': idBadgeObtido,
        'TIPOFORMATO': tipoFormato,
        'URL_FICHEIRO': urlFicheiro,
        'DATA_EMISSAO': dataEmissao,
      };
}
