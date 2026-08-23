class UsuarioModel {
  final String nome;
  final String email;
  final double metaMensal;
  final bool notificacaoVencimento;
  final bool lembreteDiario;
  final bool modoResponsavel;
  final List<CartaoModel> cartoes;

  UsuarioModel({
    required this.nome,
    required this.email,
    required this.metaMensal,
    required this.notificacaoVencimento,
    required this.lembreteDiario,
    required this.modoResponsavel,
    required this.cartoes,
  });
}

class CartaoModel {
  final String id;
  final String nome;
  final String finalNumero;
  final String bandeira;
  final bool isFamiliar;

  CartaoModel({
    required this.id,
    required this.nome,
    required this.finalNumero,
    required this.bandeira,
    required this.isFamiliar,
  });

  // Converte CartaoModel → Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'finalNumero': finalNumero,
      'bandeira': bandeira,
      'isFamiliar': isFamiliar ? 1 : 0,
    };
  }

  // Converte Map → CartaoModel
  factory CartaoModel.fromMap(Map<String, dynamic> map) {
    return CartaoModel(
      id: map['id'],
      nome: map['nome'],
      finalNumero: map['finalNumero'],
      bandeira: map['bandeira'],
      isFamiliar: map['isFamiliar'] == 1,
    );
  }
}
