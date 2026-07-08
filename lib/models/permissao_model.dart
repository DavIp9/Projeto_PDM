class Permissao {
  final int idPermissao;
  final String nome;
  final String estado;
  final String? categoria;

  Permissao({
    required this.idPermissao,
    required this.nome,
    required this.estado,
    this.categoria,
  });

  factory Permissao.fromMap(Map<String, dynamic> map) {
    return Permissao(
      idPermissao: map['IDPERMISSAO'],
      nome: map['NOME'],
      estado: map['ESTADO'],
      categoria: map['CATEGORIA'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IDPERMISSAO': idPermissao,
      'NOME': nome,
      'ESTADO': estado,
      'CATEGORIA': categoria,
    };
  }
}
