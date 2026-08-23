// lib/controllers/transacao_controller.dart
import 'package:flutter/material.dart';
import 'package:finance/features/transactions/data/models/transacao_model.dart';
import 'package:finance/features/transactions/data/repositories/transacao_repository.dart';

double calcularValorDaParcela(double valorTotal, int totalParcelas) {
  if (totalParcelas < 1) {
    throw ArgumentError.value(totalParcelas, 'totalParcelas');
  }
  return valorTotal / totalParcelas;
}

double converterValorMonetario(String texto) {
  final normalizado = texto.trim().replaceAll('R\$', '').replaceAll(' ', '');
  if (normalizado.isEmpty) return 0.0;

  final valor = normalizado.contains(',')
      ? normalizado.replaceAll('.', '').replaceAll(',', '.')
      : normalizado;
  return double.tryParse(valor) ?? 0.0;
}

DateTime adicionarMeses(DateTime data, int meses) {
  final primeiroDia = DateTime(data.year, data.month + meses, 1);
  final ultimoDia = DateTime(primeiroDia.year, primeiroDia.month + 1, 0).day;
  return DateTime(
    primeiroDia.year,
    primeiroDia.month,
    data.day > ultimoDia ? ultimoDia : data.day,
  );
}

class TransacaoController extends ChangeNotifier {
  List<TransacaoModel> transacoesFiltradas = [];
  double totalGastoMes = 0.0;
  double totalCredito = 0.0;
  double totalDebito = 0.0;
  double totalPix = 0.0;
  double totalComprometidoFuturo = 0.0;

  String filtroMetodoAtual = 'Todos';
  String filtroPeriodoAtual = 'Mês';
  int mesAtualFiltro = DateTime.now().month;
  int anoAtualFiltro = DateTime.now().year;

  // Repository em memória. O SQLite será conectado em uma etapa posterior.
  final TransacaoRepository _repository = TransacaoRepository();

  TransacaoController() {
    // CORREÇÃO AQUI: Chamamos a função de inicialização com segurança
    _inicializarController();
  }

  var parcelaAtiva = '';

  // 2. Garante que o Flutter espere o banco existir na memória antes de ler os dados
  Future<void> _inicializarController() async {
    await atualizarDashboardEHistorico();
  }

  Future<void> atualizarDashboardEHistorico() async {
    // Busca as transações mantidas pelo repository durante esta execução.
    final todas = await _repository.listarTodas();

    // Filtra apenas as transações do mês/ano selecionados
    List<TransacaoModel> doMes = todas.where((t) {
      return t.data.month == mesAtualFiltro && t.data.year == anoAtualFiltro;
    }).toList();

    if (filtroPeriodoAtual != 'Mês') {
      final agora = DateTime.now();
      final inicio = filtroPeriodoAtual == 'Hoje'
          ? DateTime(agora.year, agora.month, agora.day)
          : agora.subtract(const Duration(days: 30));
      doMes = todas.where((t) => !t.data.isBefore(inicio)).toList();
    }

    // Cálculos para o painel principal
    totalGastoMes = doMes.fold(0.0, (soma, item) => soma + item.valorParcela);
    totalCredito = doMes
        .where((t) => t.metodoPagamento == 'Crédito')
        .fold(0.0, (s, item) => s + item.valorParcela);
    totalDebito = doMes
        .where((t) => t.metodoPagamento == 'Débito')
        .fold(0.0, (s, item) => s + item.valorParcela);
    totalPix = doMes
        .where((t) => t.metodoPagamento == 'PIX')
        .fold(0.0, (s, item) => s + item.valorParcela);
    final referencia = DateTime(anoAtualFiltro, mesAtualFiltro + 1);
    totalComprometidoFuturo = todas
        .where(
          (item) =>
              item.data.isAfter(referencia.subtract(const Duration(days: 1))),
        )
        .fold(0.0, (soma, item) => soma + item.valorParcela);
    parcelaAtiva = doMes
        .where((item) => item.isParcelado)
        .fold(
          0,
          (total, item) => total + item.totalParcelas - item.parcelaAtual,
        )
        .toString();

    // Filtros para o Histórico
    if (filtroMetodoAtual == 'Todos') {
      transacoesFiltradas = [...doMes]
        ..sort((a, b) => b.data.compareTo(a.data));
    } else {
      transacoesFiltradas =
          doMes.where((t) => t.metodoPagamento == filtroMetodoAtual).toList()
            ..sort((a, b) => b.data.compareTo(a.data));
    }

    notifyListeners(); // Notifica a interface visual
  }

  Future<void> alterarFiltroMetodo(String filtro) async {
    filtroMetodoAtual = filtro;
    await atualizarDashboardEHistorico();
  }

  Future<void> alterarPeriodo(String periodo) async {
    filtroPeriodoAtual = periodo;
    await atualizarDashboardEHistorico();
  }

  Future<void> alterarMes(int mes) async {
    mesAtualFiltro = mes;
    filtroMetodoAtual = 'Todos';
    await atualizarDashboardEHistorico();
  }

  Future<void> alterarMesEAno(int mes, int ano) async {
    mesAtualFiltro = mes;
    anoAtualFiltro = ano;
    filtroPeriodoAtual = 'Mês';
    filtroMetodoAtual = 'Todos';
    await atualizarDashboardEHistorico();
  }

  Future<void> salvarGastoNoBanco({
    required String descricao,
    required double valorTotal,
    required String metodoPagamento,
    required bool isCartaoFamiliar,
    required bool isParcelado,
    required int totalParcelas,
    required String categoria,
    DateTime? data,
  }) async {
    final quantidadeParcelas = isParcelado && totalParcelas > 0
        ? totalParcelas
        : 1;
    debugPrint(
      '[TRANSACAO] Salvando "$descricao": total=$valorTotal, parcelas=$quantidadeParcelas',
    );
    final dataInicial = data ?? DateTime.now();
    final valorParcela = calcularValorDaParcela(valorTotal, quantidadeParcelas);
    final transacoes = List.generate(quantidadeParcelas, (index) {
      final dataParcela = adicionarMeses(dataInicial, index);
      return TransacaoModel(
        id: '${DateTime.now().microsecondsSinceEpoch}_$index',
        descricao: descricao,
        valorTotal: valorTotal,
        metodoPagamento: metodoPagamento,
        isCartaoFamiliar: isCartaoFamiliar,
        isParcelado: isParcelado,
        parcelaAtual: index + 1,
        totalParcelas: quantidadeParcelas,
        valorParcela: valorParcela,
        categoria: categoria,
        data: dataParcela,
      );
    });
    await _repository.salvarTodas(transacoes);
    await atualizarDashboardEHistorico();
    debugPrint(
      '[TRANSACAO] $quantidadeParcelas parcela(s) salvas com sucesso.',
    );
  }

  // ... (mantenha as funções de salvarGastoNoBanco e alterar filtros abaixo)
}
