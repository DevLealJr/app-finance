import 'package:finance/features/transactions/presentation/controllers/transacao_controller.dart';
import 'package:finance/features/account/presentation/controllers/usuario_controller.dart';
import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/features/account/data/models/usuario_model.dart';
import 'package:finance/features/transactions/data/models/gasto_fixo_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // watch() nos dois controllers: nome/cartões/preferências vêm do
    // UsuarioController, e o total gasto/parcelas ativas vêm do
    // TransacaoController (mesma ideia do comentário que já existia no
    // controller: "virá do controller de transações futuramente").
    final usuarioController = context.watch<UsuarioController>();
    final transacaoController = context.watch<TransacaoController>();

    final double meta = usuarioController.metaMensal > 0
        ? usuarioController.metaMensal
        : 5000.0;
    final double progresso = (transacaoController.totalGastoMes / meta).clamp(
      0.0,
      1.0,
    );
    final String iniciais = _iniciais(usuarioController.nome);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.surfaceColor,
                child: Text(
                  iniciais,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                usuarioController.nome.isEmpty
                    ? 'Sem nome cadastrado'
                    : usuarioController.nome,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                usuarioController.email,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 32),
              _buildSection('Meus Cartões', [
                ...usuarioController.cartoes.isEmpty
                    ? [
                        Text(
                          'Nenhum cartão cadastrado ainda.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ]
                    : usuarioController.cartoes.map(
                        (cartao) => _buildCardItem(cartao),
                      ),
                TextButton.icon(
                  onPressed: () =>
                      _abrirFormularioCartao(context, usuarioController),
                  icon: Icon(Icons.add, color: AppTheme.primaryColor, size: 18),
                  label: Text(
                    'Adicionar cartão',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Gastos Fixos', [
                if (transacaoController.gastosFixos.isEmpty)
                  Text(
                    'Nenhum gasto fixo cadastrado ainda.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  )
                else
                  ...transacaoController.gastosFixos.map(_buildGastoFixoItem),
                TextButton.icon(
                  onPressed: () =>
                      _abrirFormularioGastoFixo(context, transacaoController),
                  icon: Icon(Icons.add, color: AppTheme.primaryColor, size: 18),
                  label: Text(
                    'Adicionar gasto fixo',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Preferências', [
                _buildPreferenceToggle(
                  'Notificações de vencimento',
                  usuarioController.notificacaoVencimento,
                  (val) => usuarioController.alternarNotificacao(val),
                ),
                _buildPreferenceToggle(
                  'Lembrete de lançamento diário',
                  usuarioController.lembreteDiario,
                  (val) => usuarioController.alternarLembrete(val),
                ),
                _buildPreferenceToggle(
                  'Modo responsável',
                  usuarioController.modoResponsavel,
                  (val) => usuarioController.alternarModoResponsavel(val),
                  subtitle: 'Exige lançamento individual de cada gasto',
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Resumo do Mês', [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _nomeDoMes(transacaoController.mesAtualFiltro),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    PopupMenuButton<int>(
                      icon: const Icon(Icons.calendar_month, size: 20),
                      onSelected: (mes) async {
                        await transacaoController.alterarMes(mes);
                        await usuarioController.carregarMetaDoPeriodo(
                          mes,
                          transacaoController.anoAtualFiltro,
                        );
                      },
                      itemBuilder: (context) => List.generate(
                        12,
                        (index) => PopupMenuItem(
                          value: index + 1,
                          child: Text(_nomeDoMes(index + 1)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meta mensal',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatarMoeda(meta),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatarMoeda(transacaoController.totalGastoMes)} de ${_formatarMoeda(meta)}',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _editarMeta(
                      context,
                      usuarioController,
                      transacaoController,
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Definir orçamento deste mês'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStat(
                      'Parcelas ativas',
                      transacaoController.parcelaAtiva,
                    ),
                    const SizedBox(width: 32),
                    _buildStat(
                      'Cartões cadastrados',
                      '${usuarioController.cartoesCadastrados}',
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => _confirmarLogout(context, usuarioController),
                child: const Text(
                  'Sair da conta',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
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

  Future<void> _editarMeta(
    BuildContext context,
    UsuarioController usuarioController,
    TransacaoController transacaoController,
  ) async {
    final controller = TextEditingController(
      text: usuarioController.metaMensal.toStringAsFixed(2),
    );
    final valor = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Orçamento de ${_nomeDoMes(transacaoController.mesAtualFiltro)}',
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: 'R\$ '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              double.tryParse(controller.text.replaceAll(',', '.')),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (valor != null && valor > 0) {
      await usuarioController.salvarMetaDoPeriodo(
        mes: transacaoController.mesAtualFiltro,
        ano: transacaoController.anoAtualFiltro,
        valor: valor,
      );
    }
  }

  // Encerra a sessão: volta pro AuthGate, que mostrará a tela de Login.
  // A conta (nome, e-mail, senha) e os gastos no SQLite continuam salvos —
  // é só entrar de novo com a mesma senha na próxima vez.
  Future<void> _confirmarLogout(
    BuildContext context,
    UsuarioController controller,
  ) async {
    final bool? confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Sair da conta'),
        content: const Text(
          'Você vai precisar fazer login de novo pra acessar o app. Seus dados continuam salvos neste aparelho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await controller.deslogar();
    }
  }

  Future<void> _abrirFormularioCartao(
    BuildContext context,
    UsuarioController controller,
  ) async {
    final nomeController = TextEditingController();
    final numeroController = TextEditingController();
    final bandeiraController = TextEditingController();
    bool isFamiliar = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adicionar cartão',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do cartão (ex: Cartão Principal)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bandeiraController,
                      decoration: const InputDecoration(
                        labelText: 'Bandeira/Banco (ex: Nubank)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: numeroController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: 'Últimos 4 dígitos',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cartão familiar/de terceiro?',
                          style: TextStyle(fontSize: 13),
                        ),
                        Switch(
                          value: isFamiliar,
                          onChanged: (val) =>
                              setModalState(() => isFamiliar = val),
                          activeThumbColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final numero = numeroController.text.trim();
                          if (nomeController.text.trim().isEmpty ||
                              numero.length != 4 ||
                              int.tryParse(numero) == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Informe o nome e exatamente 4 dígitos numéricos.',
                                ),
                              ),
                            );
                            return;
                          }
                          try {
                            await controller.adicionarCartao(
                              nome: nomeController.text.trim(),
                              finalNumero: numero,
                              bandeira: bandeiraController.text.trim().isEmpty
                                  ? 'Cartão'
                                  : bandeiraController.text.trim(),
                              isFamiliar: isFamiliar,
                            );
                            if (context.mounted) Navigator.pop(context);
                          } catch (erro) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao salvar cartão: $erro'),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Salvar cartão'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _abrirFormularioGastoFixo(
    BuildContext context,
    TransacaoController controller,
  ) async {
    final descricaoController = TextEditingController();
    final valorController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar gasto fixo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (ex: Aluguel)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor mensal',
                  prefixText: 'R\$ ',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final valor = converterValorMonetario(valorController.text);
                    if (descricaoController.text.trim().isEmpty || valor <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Informe a descrição e um valor válido.',
                          ),
                        ),
                      );
                      return;
                    }
                    await controller.adicionarGastoFixo(
                      descricao: descricaoController.text.trim(),
                      valor: valor,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Salvar gasto fixo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    descricaoController.dispose();
    valorController.dispose();
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCardItem(CartaoModel cartao) {
    final Color cor = cartao.isFamiliar ? Colors.purple : Colors.blue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(Icons.credit_card, color: cor.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cartao.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '${cartao.bandeira} • **** ${cartao.finalNumero}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              ),
            ],
          ),
          if (cartao.isFamiliar) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Familiar',
                style: TextStyle(color: Colors.purple, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGastoFixoItem(GastoFixoModel gasto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.repeat, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              gasto.descricao,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Text(
            _formatarMoeda(gasto.valor),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceToggle(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13)),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
