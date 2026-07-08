class AlertaGlobal {
  final int idAlertaGlobal;
  final String mensagem;
  final String destinatario;
  final String data;
  final String estado;

  AlertaGlobal({
    required this.idAlertaGlobal,
    required this.mensagem,
    required this.destinatario,
    required this.data,
    required this.estado,
  });

  factory AlertaGlobal.fromMap(Map<String, dynamic> map) {
    return AlertaGlobal(
      idAlertaGlobal: map['IDALERTAGLOBAL'],
      mensagem: map['MENSAGEM'],
      destinatario: map['DESTINATARIO'],
      data: map['DATA'],
      estado: map['ESTADO'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IDALERTAGLOBAL': idAlertaGlobal,
      'MENSAGEM': mensagem,
      'DESTINATARIO': destinatario,
      'DATA': data,
      'ESTADO': estado,
    };
  }
}
