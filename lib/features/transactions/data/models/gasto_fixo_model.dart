import 'package:finance/core/money/money.dart';

class GastoFixoModel {
  final String id;
  final String descricao;
  final int valorCentavos;

  GastoFixoModel({
    required this.id,
    required this.descricao,
    required double valor,
  }) : valorCentavos = valorEmCentavos(valor);

  double get valor => valorDeCentavos(valorCentavos);

  Map<String, dynamic> toMap() {
    return {'id': id, 'descricao': descricao, 'valor': valorCentavos};
  }

  factory GastoFixoModel.fromMap(Map<String, dynamic> map) {
    return GastoFixoModel(
      id: map['id'] as String,
      descricao: map['descricao'] as String,
      valor: valorDeCentavos((map['valor'] as num).round()),
    );
  }
}
