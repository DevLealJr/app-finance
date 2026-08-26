import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/features/transactions/presentation/controllers/transacao_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance/features/account/presentation/controllers/usuario_controller.dart';

class PainelPage extends StatelessWidget {
  const PainelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransacaoController, UsuarioController>(
      builder: (context, controller, usuarioController, child) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, controller),
                const SizedBox(height: 32),
                _buildSummaryChart(controller, usuarioController.metaMensal),
                const SizedBox(height: 32),
                _buildBalanceSection(controller),
                const SizedBox(height: 16),
                _buildPlanningSection(
                  controller,
                  usuarioController,
                  usuarioController.metaMensal,
                ),
                const SizedBox(height: 32),
                _buildCategoriesSection(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TransacaoController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MeuControle',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Resumo Mensal',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          // Torna todo o container clicável
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final transacaoController = context.read<TransacaoController>();
              final usuarioController = context.read<UsuarioController>();
              // 1. Pega a posição exata do container na tela para abrir o menu no lugar certo
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final offset = renderBox.localToGlobal(Offset.zero);

              // 2. Abre o menu suspenso com a lista de todos os meses do ano
              final String? mesEscolhido = await showMenu<String>(
                context: context,
                // Posiciona o menu logo abaixo ou sobre o container
                position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy + renderBox.size.height,
                  offset.dx + renderBox.size.width,
                  0,
                ),
                // Gera as opções de Janeiro a Dezembro dinamicamente
                items:
                    [
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
                    ].map((String mes) {
                      return PopupMenuItem<String>(
                        value: mes,
                        child: Text(mes),
                      );
                    }).toList(),
              );

              // 3. Executa a ação caso o usuário tenha clicado em algum mês
              if (mesEscolhido != null) {
                // Se seu widget for Stateful, você pode atualizar uma variável aqui:
                // setState(() { mesSelecionado = mesEscolhido; });
                final mes =
                    [
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
                    ].indexOf(mesEscolhido) +
                    1;
                if (mes > 0) {
                  await transacaoController.alterarMes(mes);
                  await usuarioController.carregarMetaDoPeriodo(
                    mes,
                    transacaoController.anoAtualFiltro,
                  );
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min, // Mantém a Row compacta
              children: [
                Text(
                  '${_nomeDoMes(controller.mesAtualFiltro)} ${controller.anoAtualFiltro}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4), // Pequeno espaçamento opcional
                const Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryChart(TransacaoController controller, double meta) {
    final progresso = meta > 0
        ? (controller.totalGastoMes / meta).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progresso,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progresso * 100).round()}%',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'GASTO',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Gasto no Mês',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                Text(
                  _formatarMoeda(controller.totalGastoMes),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Futuro comprometido: ${_formatarMoeda(controller.totalComprometidoFuturo)}',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(TransacaoController controller) {
    return Row(
      children: [
        _buildBalanceItem('Crédito', _formatarMoeda(controller.totalCredito)),
        const SizedBox(width: 12),
        _buildBalanceItem('Débito', _formatarMoeda(controller.totalDebito)),
        const SizedBox(width: 12),
        _buildBalanceItem('PIX', _formatarMoeda(controller.totalPix)),
      ],
    );
  }

  Widget _buildPlanningSection(
    TransacaoController controller,
    UsuarioController usuarioController,
    double meta,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _buildBalanceItem(
              'Gastos fixos',
              _formatarMoeda(controller.totalGastosFixos),
            ),
            const SizedBox(width: 12),
            _buildBalanceItem(
              'A receber',
              _formatarMoeda(controller.totalAReceber),
            ),
          ],
        ),
        if (controller.totaisPorCartao.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildCardTotals(controller, usuarioController),
        ],
        if (controller.totalAGuardar > 0) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.savings_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Total a guardar para ${_nomeDoMes(controller.mesAtualFiltro)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  _formatarMoeda(controller.totalAGuardar),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCardTotals(
    TransacaoController controller,
    UsuarioController usuarioController,
  ) {
    final cartoesPorId = {
      for (final cartao in usuarioController.cartoes) cartao.id: cartao,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total por cartão',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...controller.totaisPorCartao.entries.map((entry) {
          final cartao = cartoesPorId[entry.key];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cartao?.nome ?? 'Cartão não cadastrado'),
                Text(
                  _formatarMoeda(entry.value),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBalanceItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(TransacaoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorias',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: controller.totaisPorCategoria.isEmpty
              ? [const Text('Nenhum gasto cadastrado neste mês.')]
              : controller.totaisPorCategoria.entries
                    .map(
                      (entry) => _buildCategoryCard(
                        entry.key,
                        _formatarMoeda(entry.value),
                        Icons.category,
                        AppTheme.primaryColor,
                      ),
                    )
                    .toList(),
        ),
      ],
    );
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
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

  Widget _buildCategoryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.7), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
