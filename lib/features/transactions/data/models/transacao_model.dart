// lib/models/transacao_model.dart
import 'package:finance/core/money/money.dart';

class TransacaoModel {
  final String id;
  final String descricao;
  final int valorTotalCentavos;
  final String metodoPagamento;
  final String? cartaoId;
  final bool isCartaoFamiliar;
  final bool isParcelado;
  final int parcelaAtual;
  final int totalParcelas;
  final int valorParcelaCentavos;
  final String categoria;
  final DateTime data;
  final bool pago;

  TransacaoModel({
    required this.id,
    required this.descricao,
    required double valorTotal,
    required this.metodoPagamento,
    this.cartaoId,
    required this.isCartaoFamiliar,
    required this.isParcelado,
    required this.parcelaAtual,
    required this.totalParcelas,
    required double valorParcela,
    required this.categoria,
    required this.data,
    this.pago = false,
  }) : valorTotalCentavos = valorEmCentavos(valorTotal),
       valorParcelaCentavos = valorEmCentavos(valorParcela);

  double get valorTotal => valorDeCentavos(valorTotalCentavos);
  double get valorParcela => valorDeCentavos(valorParcelaCentavos);

  // Converte o Objeto Dart para um Mapa que o SQLite entende
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'valorTotal': valorTotalCentavos,
      'metodoPagamento': metodoPagamento,
      'cartao_id': cartaoId,
      'isCartaoFamiliar': isCartaoFamiliar
          ? 1
          : 0, // SQLite não guarda bool, usamos 0 ou 1
      'isParcelado': isParcelado ? 1 : 0,
      'parcelaAtual': parcelaAtual,
      'totalParcelas': totalParcelas,
      'valorParcela': valorParcelaCentavos,
      'categoria': categoria,
      'data': data.toIso8601String(), // Transforma Data em Texto
      'pago': pago ? 1 : 0,
    };
  }

  // Converte o Mapa do SQLite de volta para o Objeto Dart do Flutter
  factory TransacaoModel.fromMap(Map<String, dynamic> map) {
    return TransacaoModel(
      id: map['id'],
      descricao: map['descricao'],
      valorTotal: valorDeCentavos((map['valorTotal'] as num).round()),
      metodoPagamento: map['metodoPagamento'],
      cartaoId: map['cartao_id'] as String?,
      isCartaoFamiliar: map['isCartaoFamiliar'] == 1,
      isParcelado: map['isParcelado'] == 1,
      parcelaAtual: map['parcelaAtual'],
      totalParcelas: map['totalParcelas'],
      valorParcela: valorDeCentavos((map['valorParcela'] as num).round()),
      categoria: map['categoria'],
      data: DateTime.parse(map['data']),
      pago: map['pago'] == 1,
    );
  }
}
