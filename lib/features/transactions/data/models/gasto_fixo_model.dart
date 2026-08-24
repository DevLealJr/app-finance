class GastoFixoModel {
  final String id;
  final String descricao;
  final double valor;

  const GastoFixoModel({
    required this.id,
    required this.descricao,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'descricao': descricao, 'valor': valor};
  }

  factory GastoFixoModel.fromMap(Map<String, dynamic> map) {
    return GastoFixoModel(
      id: map['id'] as String,
      descricao: map['descricao'] as String,
      valor: (map['valor'] as num).toDouble(),
    );
  }
}
