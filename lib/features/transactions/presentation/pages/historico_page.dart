import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/features/transactions/presentation/controllers/transacao_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransacaoController>(
      builder: (context, controller, child) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Histórico',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (periodo) {
                        final partes = periodo.split('-');
                        controller.alterarMesEAno(
                          int.parse(partes[0]),
                          int.parse(partes[1]),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_nomeDoMes(controller.mesAtualFiltro)} ${controller.anoAtualFiltro}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      itemBuilder: (context) => [
                        for (
                          var ano = DateTime.now().year - 1;
                          ano <= DateTime.now().year + 1;
                          ano++
                        )
                          for (var mes = 1; mes <= 12; mes++)
                            PopupMenuItem(
                              value: '$mes-$ano',
                              child: Text('${_nomeDoMes(mes)} $ano'),
                            ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(controller, 'Todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip(controller, 'Crédito'),
                      const SizedBox(width: 8),
                      _buildFilterChip(controller, 'Débito'),
                      const SizedBox(width: 8),
                      _buildFilterChip(controller, 'PIX'),
                      const SizedBox(width: 8),
                      _buildFilterChip(controller, 'Hoje'),
                      const SizedBox(width: 8),
                      _buildFilterChip(controller, 'Últimos 30 dias'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'ÚLTIMOS LANÇAMENTOS',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: controller.transacoesFiltradas.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum lançamento encontrado para este filtro.',
                            style: TextStyle(color: AppTheme.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView(
                          children: controller.transacoesFiltradas
                              .map(
                                (transacao) => _buildTransactionItem(
                                  transacao.descricao,
                                  '${_formatarData(transacao.data)} • ${transacao.metodoPagamento} • ${transacao.parcelaAtual}/${transacao.totalParcelas}',
                                  '-R\$ ${transacao.valorParcela.toStringAsFixed(2).replaceAll('.', ',')}',
                                  Icons.category,
                                  AppTheme.primaryColor,
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(TransacaoController controller, String label) {
    final isPeriodo = label == 'Hoje' || label == 'Últimos 30 dias';
    final isSelected = isPeriodo
        ? controller.filtroPeriodoAtual ==
              (label == 'Hoje' ? 'Hoje' : '30 dias')
        : controller.filtroMetodoAtual == label;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => isPeriodo
          ? controller.alterarPeriodo(label == 'Hoje' ? 'Hoje' : '30 dias')
          : controller.alterarFiltroMetodo(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.backgroundColor : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _nomeDoMes(int mes) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return meses[mes - 1];
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
