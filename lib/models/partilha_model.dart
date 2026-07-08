class Partilha {
  final int idPartilha;
  final int idBadgeObtido;
  final String tipoPartilha;
  final String dataPartilha;
  final String urlPartilha;

  Partilha({
    required this.idPartilha,
    required this.idBadgeObtido,
    required this.tipoPartilha,
    required this.dataPartilha,
    required this.urlPartilha,
  });

  factory Partilha.fromMap(Map<String, dynamic> map) {
    return Partilha(
      idPartilha: map['ID_PARTILHA'],
      idBadgeObtido: map['ID_BADGEOBTIDO'],
      tipoPartilha: map['TIPOPARTILHA'],
      dataPartilha: map['DATAPARTILHA'],
      urlPartilha: map['URL_PARTILHA'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_PARTILHA': idPartilha,
        'ID_BADGEOBTIDO': idBadgeObtido,
        'TIPOPARTILHA': tipoPartilha,
        'DATAPARTILHA': dataPartilha,
        'URL_PARTILHA': urlPartilha,
      };
}
