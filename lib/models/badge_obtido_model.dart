class BadgeObtido {
  final int idBadgeObtido;
  final int idBadge;
  final int idUtilizador;
  final String dataObtencao;
  final String? dataExpiracao;
  final int pontuacao;
  final String fase;

  BadgeObtido({
    required this.idBadgeObtido,
    required this.idBadge,
    required this.idUtilizador,
    required this.dataObtencao,
    this.dataExpiracao,
    required this.pontuacao,
    required this.fase,
  });

  factory BadgeObtido.fromMap(Map<String, dynamic> map) {
    return BadgeObtido(
      idBadgeObtido: map['ID_BADGEOBTIDO'],
      idBadge: map['ID_BADGE'],
      idUtilizador: map['ID_UTILIZADOR'],
      dataObtencao: map['DATAOBTENCAO'],
      dataExpiracao: map['DATAEXPIRACAO'],
      pontuacao: map['PONTUACAO'],
      fase: map['FASE'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_BADGEOBTIDO': idBadgeObtido,
      'ID_BADGE': idBadge,
      'ID_UTILIZADOR': idUtilizador,
      'DATAOBTENCAO': dataObtencao,
      'DATAEXPIRACAO': dataExpiracao,
      'PONTUACAO': pontuacao,
      'FASE': fase,
    };
  }
}
