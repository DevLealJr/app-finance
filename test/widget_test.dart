// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/transactions/presentation/controllers/transacao_controller.dart';

void main() {
  test('calcula o valor mensal de uma compra parcelada', () {
    expect(calcularValorDaParcela(3000, 10), 300);
  });

  test('compra a vista permanece em uma parcela', () {
    expect(calcularValorDaParcela(250, 1), 250);
  });

  test('converte valores monetários brasileiros', () {
    expect(converterValorMonetario('3.000,50'), 3000.50);
    expect(converterValorMonetario('250,00'), 250.0);
  });
}
