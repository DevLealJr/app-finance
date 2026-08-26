import 'package:finance/core/money/money.dart';
import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/features/transactions/data/models/recebimento_model.dart';
import 'package:finance/features/transactions/presentation/controllers/transacao_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecebimentosPage extends StatefulWidget {
  const RecebimentosPage({super.key});

  @override
  State<RecebimentosPage> createState() => _RecebimentosPageState();
}

class _RecebimentosPageState extends State<RecebimentosPage> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  String _categoria = 'Salário';
  DateTime _data = DateTime.now();
  bool _recebido = false;
  bool _salvando = false;

  static const _categorias = ['Salário', 'Freelance', 'Investimentos', 'Outros'];

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _adicionar() async {
    final descricao = _descricaoController.text.trim();
    final valor = converterValorMonetario(_valorController.text);
    if (descricao.isEmpty || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma descrição e um valor válido.')),
      );
      return;
    }
    setState(() => _salvando = true);
    try {
      await context.read<TransacaoController>().adicionarRecebimento(
        descricao: descricao,
        valor: valor,
        categoria: _categoria,
        data: _data,
        recebido: _recebido,
      );
      _descricaoController.clear();
      _valorController.clear();
      if (mounted) setState(() => _salvando = false);
    } catch (erro) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: $erro')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransacaoController>(
      builder: (context, controller, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Recebimentos'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Row(
              children: [
                Expanded(child: _buildTotal('Recebido', controller.totalRecebidoMes)),
                const SizedBox(width: 12),
                Expanded(child: _buildTotal('Em aberto', controller.totalEmAbertoMes)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Novo recebimento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição', hintText: 'Ex.: Salário de agosto'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: _categorias.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setState(() => _categoria = value ?? _categoria),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Data prevista'),
                TextButton.icon(
                  onPressed: _selecionarData,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text('${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}'),
                ),
              ],
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Já foi recebido?'),
              value: _recebido,
              onChanged: (value) => setState(() => _recebido = value),
              activeThumbColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _adicionar,
                icon: const Icon(Icons.add),
                label: Text(_salvando ? 'Salvando...' : 'Adicionar recebimento'),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Controle do mês', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (controller.recebimentos.isEmpty)
              Text('Nenhum recebimento cadastrado.', style: TextStyle(color: AppTheme.textSecondary))
            else
              ...controller.recebimentos.map((item) => _buildItem(context, controller, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotal(String label, double valor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        Text(formatarCentavos(valorEmCentavos(valor)), style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildItem(BuildContext context, TransacaoController controller, RecebimentoModel item) {
    final cor = item.recebido ? Colors.greenAccent : AppTheme.primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(item.recebido ? Icons.check_circle : Icons.schedule, color: cor),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('${item.categoria} • ${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')}/${item.data.year}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(formatarCentavos(item.valorCentavos), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => controller.marcarRecebimento(item, !item.recebido),
            child: Text(item.recebido ? 'Desfazer' : 'Marcar recebido'),
          ),
        ]),
      ]),
    );
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data != null && mounted) setState(() => _data = data);
  }
}
