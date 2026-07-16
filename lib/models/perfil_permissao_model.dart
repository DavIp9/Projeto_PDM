class PerfilPermissao {
  final int idPerfil;
  final int idPermissao;

  PerfilPermissao({
    required this.idPerfil,
    required this.idPermissao,
  });

  factory PerfilPermissao.fromMap(Map<String, dynamic> map) {
    return PerfilPermissao(
      idPerfil: map['ID_PERFIL'],
      idPermissao: map['IDPERMISSAO'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_PERFIL': idPerfil,
      'IDPERMISSAO': idPermissao,
    };
  }
}
