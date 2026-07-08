class Perfil {
  final int idPerfil;
  final String nomePerfil;
  final String? descricao;

  Perfil({
    required this.idPerfil,
    required this.nomePerfil,
    this.descricao,
  });

  factory Perfil.fromMap(Map<String, dynamic> map) {
    return Perfil(
      idPerfil: map['ID_PERFIL'],
      nomePerfil: map['NOME_PERFIL'],
      descricao: map['DESCRICAO'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_PERFIL': idPerfil,
      'NOME_PERFIL': nomePerfil,
      'DESCRICAO': descricao,
    };
  }
}
