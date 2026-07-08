class Configuracao {
  final int idConfiguracao;
  final String nome;
  final int valor;
  final String? descricao;

  Configuracao({
    required this.idConfiguracao,
    required this.nome,
    required this.valor,
    this.descricao,
  });

  factory Configuracao.fromMap(Map<String, dynamic> map) {
    return Configuracao(
      idConfiguracao: map['IDCONFIGURACAO'],
      nome: map['NOME'],
      valor: map['VALOR'],
      descricao: map['DESCRICAO'],
    );
  }

  Map<String, dynamic> toMap() => {
        'IDCONFIGURACAO': idConfiguracao,
        'NOME': nome,
        'VALOR': valor,
        'DESCRICAO': descricao,
      };
}
