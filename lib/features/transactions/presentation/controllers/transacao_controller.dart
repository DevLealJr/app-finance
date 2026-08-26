// lib/controllers/transacao_controller.dart
import 'package:flutter/material.dart';
import 'package:finance/features/transactions/data/models/transacao_model.dart';
import 'package:finance/features/transactions/data/models/gasto_fixo_model.dart';
import 'package:finance/features/transactions/data/repositories/transacao_repository.dart';
import 'package:finance/features/account/data/repositories/usuario_repository.dart';
import 'package:finance/core/money/money.dart';

double calcularValorDaParcela(double valorTotal, int totalParcelas) {
  if (totalParcelas < 1) {
    throw ArgumentError.value(totalParcelas, 'totalParcelas');
  }
  final totalCentavos = valorEmCentavos(valorTotal);
  final centavosBase = totalCentavos ~/ totalParcelas;
  final restoCentavos = totalCentavos % totalParcelas;
  return valorDeCentavos(centavosBase + (restoCentavos > 0 ? 1 : 0));
}

double converterValorMonetario(String texto) {
  return valorDeCentavos(parseCentavos(texto));
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

Map<String, double> agruparValoresPorCategoria(
  Iterable<TransacaoModel> transacoes,
) {
  final totais = <String, double>{};
  for (final transacao in transacoes) {
    totais.update(
      transacao.categoria,
      (total) => total + transacao.valorParcela,
      ifAbsent: () => transacao.valorParcela,
    );
  }
  return totais;
}

Map<String, double> agruparValoresPorCartao(
  Iterable<TransacaoModel> transacoes,
) {
  final totais = <String, double>{};
  for (final transacao in transacoes) {
    final cartaoId = transacao.cartaoId;
    if (cartaoId == null) continue;
    totais.update(
      cartaoId,
      (total) => total + transacao.valorParcela,
      ifAbsent: () => transacao.valorParcela,
    );
  }
  return totais;
}

class TransacaoController extends ChangeNotifier {
  List<TransacaoModel> transacoesFiltradas = [];
  double totalGastoMes = 0.0;
  double totalCredito = 0.0;
  double totalDebito = 0.0;
  double totalPix = 0.0;
  double totalComprometidoFuturo = 0.0;
  double totalCartaoFamiliar = 0.0;
  double totalAReceber = 0.0;
  double totalGastosFixos = 0.0;
  double totalAGuardar = 0.0;
  double totalPago = 0.0;
  Map<String, double> totaisPorCartao = {};
  Map<String, double> totaisPorCategoria = {};
  List<GastoFixoModel> gastosFixos = [];

  String filtroMetodoAtual = 'Todos';
  String filtroPeriodoAtual = 'Mês';
  int mesAtualFiltro = DateTime.now().month;
  int anoAtualFiltro = DateTime.now().year;

  final TransacaoRepository _repository = TransacaoRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  TransacaoController() {
    // CORREÇÃO AQUI: Chamamos a função de inicialização com segurança
    _inicializarController();
  }

  var parcelaAtiva = '';

  // 2. Garante que o Flutter espere o banco existir na memória antes de ler os dados
  Future<void> _inicializarController() async {
    try {
      await _carregarGastosFixos();
      await atualizarDashboardEHistorico();
    } catch (erro, stackTrace) {
      debugPrint('[TRANSACAO][ERRO] Falha ao carregar dados: $erro');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> recarregarDados() async {
    await _carregarGastosFixos();
    await atualizarDashboardEHistorico();
  }

  Future<void> _carregarGastosFixos() async {
    final usuario = await _usuarioRepository.usuarioAtual();
    if (usuario == null) return;
    gastosFixos = await _repository.listarGastosFixos(
      usuarioId: usuario['id']! as String,
    );
  }

  Future<void> adicionarGastoFixo({
    required String descricao,
    required double valor,
  }) async {
    final usuario = await _usuarioRepository.usuarioAtual();
    if (usuario == null) return;
    final gasto = GastoFixoModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      descricao: descricao,
      valor: valor,
    );
    await _repository.salvarGastoFixo(
      gasto,
      usuarioId: usuario['id']! as String,
    );
    gastosFixos = [...gastosFixos, gasto];
    await atualizarDashboardEHistorico();
  }

  Future<void> atualizarDashboardEHistorico() async {
    final usuario = await _usuarioRepository.usuarioAtual();
    final todas = usuario == null
        ? <TransacaoModel>[]
        : await _repository.listarTodas(usuarioId: usuario['id']! as String);

    // Filtra apenas as transações do mês/ano selecionados
    List<TransacaoModel> doMes = todas.where((t) {
      return t.data.month == mesAtualFiltro && t.data.year == anoAtualFiltro;
    }).toList();

    if (filtroPeriodoAtual != 'Mês') {
      final agora = DateTime.now();
      final inicio = filtroPeriodoAtual == 'Hoje'
          ? DateTime(agora.year, agora.month, agora.day)
          : agora.subtract(const Duration(days: 30));
      doMes = todas
          .where((t) => !t.data.isBefore(inicio) && !t.data.isAfter(agora))
          .toList();
    }

    // Cálculos para o painel principal
    totalGastosFixos = gastosFixos.fold(
      0.0,
      (soma, gasto) => soma + gasto.valor,
    );
    totalPago = doMes
        .where((item) => item.pago)
        .fold(0.0, (soma, item) => soma + item.valorParcela);
    totalCartaoFamiliar = doMes
        .where((item) => item.isCartaoFamiliar && !item.pago)
        .fold(0.0, (soma, item) => soma + item.valorParcela);
    totalAReceber = totalCartaoFamiliar;
    totaisPorCartao = agruparValoresPorCartao(doMes);
    totaisPorCategoria = agruparValoresPorCategoria(doMes);
    totalGastoMes =
        doMes.fold(0.0, (soma, item) => soma + item.valorParcela) +
        totalGastosFixos;
    totalAGuardar = 0.0;
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
    totalComprometidoFuturo += totalGastosFixos;
    parcelaAtiva = doMes
        .where((item) => item.isParcelado)
        .fold(
          0,
          (total, item) => total + item.totalParcelas - item.parcelaAtual,
        )
        .toString();
    final metaAtual = await _metaAtual();
    totalAGuardar = totalGastoMes > metaAtual ? totalGastoMes - metaAtual : 0.0;

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

  Future<double> _metaAtual() async {
    final usuario = await _usuarioRepository.usuarioAtual();
    if (usuario == null) return 5000.0;
    final configuracoes = await _usuarioRepository.listarConfiguracoes(
      usuario['id']! as String,
    );
    return double.tryParse(
          configuracoes['meta_mensal_${anoAtualFiltro}_$mesAtualFiltro'] ?? '',
        ) ??
        double.tryParse(configuracoes['meta_mensal'] ?? '') ??
        5000.0;
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
    String? cartaoId,
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
    final totalCentavos = valorEmCentavos(valorTotal);
    final centavosBase = totalCentavos ~/ quantidadeParcelas;
    final restoCentavos = totalCentavos % quantidadeParcelas;
    final transacoes = List.generate(quantidadeParcelas, (index) {
      final dataParcela = adicionarMeses(dataInicial, index);
      final parcelaCentavos = centavosBase + (index < restoCentavos ? 1 : 0);
      return TransacaoModel(
        id: '${DateTime.now().microsecondsSinceEpoch}_$index',
        descricao: descricao,
        valorTotal: valorTotal,
        metodoPagamento: metodoPagamento,
        cartaoId: cartaoId,
        isCartaoFamiliar: isCartaoFamiliar,
        isParcelado: isParcelado,
        parcelaAtual: index + 1,
        totalParcelas: quantidadeParcelas,
        valorParcela: valorDeCentavos(parcelaCentavos),
        categoria: categoria,
        data: dataParcela,
      );
    });
    final usuario = await _usuarioRepository.usuarioAtual();
    if (usuario == null) return;
    await _repository.salvarTodas(
      transacoes,
      usuarioId: usuario['id']! as String,
    );
    await atualizarDashboardEHistorico();
    debugPrint(
      '[TRANSACAO] $quantidadeParcelas parcela(s) salvas com sucesso.',
    );
  }

  Future<void> marcarComoPago(TransacaoModel transacao, bool pago) async {
    final usuario = await _usuarioRepository.usuarioAtual();
    if (usuario == null) return;
    await _repository.atualizarPagamento(
      transacao.id,
      usuarioId: usuario['id']! as String,
      pago: pago,
    );
    await atualizarDashboardEHistorico();
  }

  Future<void> editarGastoFixo(GastoFixoModel gasto) async {
    final usuario = await _usuarioRepository.usuarioAtual();
    if (usuario == null) return;
    await _repository.atualizarGastoFixo(
      gasto,
      usuarioId: usuario['id']! as String,
    );
    await _carregarGastosFixos();
    await atualizarDashboardEHistorico();
  }

  Future<void> excluirGastoFixo(String id) async {
    final usuario = await _usuarioRepository.usuarioAtual();
    if (usuario == null) return;
    await _repository.excluirGastoFixo(id, usuarioId: usuario['id']! as String);
    await _carregarGastosFixos();
    await atualizarDashboardEHistorico();
  }

  // ... (mantenha as funções de salvarGastoNoBanco e alterar filtros abaixo)
}
