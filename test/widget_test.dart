// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/transactions/presentation/controllers/transacao_controller.dart';
import 'package:finance/features/transactions/data/models/transacao_model.dart';

void main() {
  test('calcula o valor mensal de uma compra parcelada', () {
    expect(calcularValorDaParcela(3000, 10), 300);
  });

  test('compra a vista permanece em uma parcela', () {
    expect(calcularValorDaParcela(250, 1), 250);
  });

  test('primeira parcela recebe o resto dos centavos', () {
    expect(calcularValorDaParcela(100, 3), 33.34);
  });

  test('agrupa valores por categoria e cartão', () {
    final transacoes = [
      TransacaoModel(
        id: '1',
        descricao: 'Mercado',
        valorTotal: 100,
        valorParcela: 60,
        metodoPagamento: 'Crédito',
        cartaoId: 'cartao-1',
        isCartaoFamiliar: false,
        isParcelado: false,
        parcelaAtual: 1,
        totalParcelas: 1,
        categoria: 'Alimentação',
        data: DateTime(2026, 8, 1),
      ),
      TransacaoModel(
        id: '2',
        descricao: 'Farmácia',
        valorTotal: 40,
        valorParcela: 40,
        metodoPagamento: 'Crédito',
        cartaoId: 'cartao-1',
        isCartaoFamiliar: false,
        isParcelado: false,
        parcelaAtual: 1,
        totalParcelas: 1,
        categoria: 'Saúde',
        data: DateTime(2026, 8, 2),
      ),
    ];
    expect(agruparValoresPorCategoria(transacoes), {
      'Alimentação': 60,
      'Saúde': 40,
    });
    expect(agruparValoresPorCartao(transacoes), {'cartao-1': 100});
  });

  test('converte valores monetários brasileiros', () {
    expect(converterValorMonetario('3.000,50'), 3000.50);
    expect(converterValorMonetario('250,00'), 250.0);
    expect(converterValorMonetario('R\$ 1.234,56'), 1234.56);
    expect(converterValorMonetario('invalido'), 0.0);
  });

  test('recusa quantidade de parcelas inválida', () {
    expect(() => calcularValorDaParcela(100, 0), throwsArgumentError);
  });

  test('limita datas ao último dia do mês', () {
    expect(adicionarMeses(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
  });
}
