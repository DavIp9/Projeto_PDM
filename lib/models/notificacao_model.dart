class Notificacao {
  final int idNotificacao;
  final int? idBadgeObtido;
  final int? idCandidatura;
  final int? idUtilizador;
  final String tipoNotificacao;
  final String? mensagem;
  final String dataCriacao;
  final String fase;
  final String titulo;

  Notificacao({
    required this.idNotificacao,
    this.idBadgeObtido,
    this.idCandidatura,
    this.idUtilizador,
    required this.tipoNotificacao,
    this.mensagem,
    required this.dataCriacao,
    required this.fase,
    required this.titulo,
  });

  factory Notificacao.fromMap(Map<String, dynamic> map) {
    return Notificacao(
      idNotificacao: map['ID_NOTIFICACAO'],
      idBadgeObtido: map['ID_BADGEOBTIDO'],
      idCandidatura: map['ID_CANDIDATURA'],
      idUtilizador: map['ID_UTILIZADOR'],
      tipoNotificacao: map['TIPO_NOTIFICACAO'],
      mensagem: map['MENSAGEM'],
      dataCriacao: map['DATACRIACAO'],
      fase: map['FASE'],
      titulo: map['TITULO'],
    );
  }

  Map<String, dynamic> toMap() => {
        'ID_NOTIFICACAO': idNotificacao,
        'ID_BADGEOBTIDO': idBadgeObtido,
        'ID_CANDIDATURA': idCandidatura,
        'ID_UTILIZADOR': idUtilizador,
        'TIPO_NOTIFICACAO': tipoNotificacao,
        'MENSAGEM': mensagem,
        'DATACRIACAO': dataCriacao,
        'FASE': fase,
        'TITULO': titulo,
      };
}
