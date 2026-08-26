int valorEmCentavos(double valor) => (valor * 100).round();

double valorDeCentavos(int centavos) => centavos / 100;

int parseCentavos(String texto) {
  final normalizado = texto.trim().replaceAll('R\$', '').replaceAll(' ', '');
  if (normalizado.isEmpty) return 0;
  final valor = normalizado.contains(',')
      ? normalizado.replaceAll('.', '').replaceAll(',', '.')
      : normalizado;
  final parsed = double.tryParse(valor);
  return parsed == null ? 0 : valorEmCentavos(parsed);
}

String formatarCentavos(int centavos) {
  final negativo = centavos < 0;
  final absoluto = centavos.abs();
  final reais = absoluto ~/ 100;
  final centavosTexto = (absoluto % 100).toString().padLeft(2, '0');
  final reaisTexto = reais.toString().replaceAllMapped(
    RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${negativo ? '-' : ''}R\$ $reaisTexto,$centavosTexto';
}
