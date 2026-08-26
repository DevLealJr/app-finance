import 'package:finance/core/money/money.dart';

class RecebimentoModel {
  final String id;
  final String descricao;
  final int valorCentavos;
  final String categoria;
  final DateTime data;
  final bool recebido;

  RecebimentoModel({
    required this.id,
    required this.descricao,
    required double valor,
    required this.categoria,
    required this.data,
    this.recebido = false,
  }) : valorCentavos = valorEmCentavos(valor);

  double get valor => valorDeCentavos(valorCentavos);

  Map<String, dynamic> toMap() => {
    'id': id,
    'descricao': descricao,
    'valor': valorCentavos,
    'categoria': categoria,
    'data': data.toIso8601String(),
    'recebido': recebido ? 1 : 0,
  };

  factory RecebimentoModel.fromMap(Map<String, dynamic> map) {
    return RecebimentoModel(
      id: map['id'] as String,
      descricao: map['descricao'] as String,
      valor: valorDeCentavos((map['valor'] as num).round()),
      categoria: map['categoria'] as String,
      data: DateTime.parse(map['data'] as String),
      recebido: map['recebido'] == 1,
    );
  }
}
