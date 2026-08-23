// lib/models/transacao_model.dart
class TransacaoModel {
  final String id;
  final String descricao;
  final double valorTotal;
  final String metodoPagamento;
  final bool isCartaoFamiliar;
  final bool isParcelado;
  final int parcelaAtual;
  final int totalParcelas;
  final double valorParcela;
  final String categoria;
  final DateTime data;

  TransacaoModel({
    required this.id,
    required this.descricao,
    required this.valorTotal,
    required this.metodoPagamento,
    required this.isCartaoFamiliar,
    required this.isParcelado,
    required this.parcelaAtual,
    required this.totalParcelas,
    required this.valorParcela,
    required this.categoria,
    required this.data,
  });

  // Converte o Objeto Dart para um Mapa que o SQLite entende
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'valorTotal': valorTotal,
      'metodoPagamento': metodoPagamento,
      'isCartaoFamiliar': isCartaoFamiliar
          ? 1
          : 0, // SQLite não guarda bool, usamos 0 ou 1
      'isParcelado': isParcelado ? 1 : 0,
      'parcelaAtual': parcelaAtual,
      'totalParcelas': totalParcelas,
      'valorParcela': valorParcela,
      'categoria': categoria,
      'data': data.toIso8601String(), // Transforma Data em Texto
    };
  }

  // Converte o Mapa do SQLite de volta para o Objeto Dart do Flutter
  factory TransacaoModel.fromMap(Map<String, dynamic> map) {
    return TransacaoModel(
      id: map['id'],
      descricao: map['descricao'],
      valorTotal: map['valorTotal'],
      metodoPagamento: map['metodoPagamento'],
      isCartaoFamiliar: map['isCartaoFamiliar'] == 1,
      isParcelado: map['isParcelado'] == 1,
      parcelaAtual: map['parcelaAtual'],
      totalParcelas: map['totalParcelas'],
      valorParcela: map['valorParcela'],
      categoria: map['categoria'],
      data: DateTime.parse(map['data']),
    );
  }
}
