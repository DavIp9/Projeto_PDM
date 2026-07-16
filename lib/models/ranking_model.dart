class Ranking {
  final int idRanking;
  final int idUtilizador;
  final String tipo;
  final int ano;
  final int mes;
  final int pontosGanhos;
  final int badgesGanhos;

  Ranking({
    required this.idRanking,
    required this.idUtilizador,
    required this.tipo,
    required this.ano,
    required this.mes,
    required this.pontosGanhos,
    required this.badgesGanhos,
  });

  factory Ranking.fromMap(Map<String, dynamic> map) {
    return Ranking(
      idRanking: map['ID_RANKING'],
      idUtilizador: map['ID_UTILIZADOR'],
      tipo: map['TIPO'],
      ano: map['ANO'],
      mes: map['MES'],
      pontosGanhos: map['PONTOSGANHOS'],
      badgesGanhos: map['BADGESGANHOS'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_RANKING': idRanking,
        'ID_UTILIZADOR': idUtilizador,
        'TIPO': tipo,
        'ANO': ano,
        'MES': mes,
        'PONTOSGANHOS': pontosGanhos,
        'BADGESGANHOS': badgesGanhos,
      };
}
