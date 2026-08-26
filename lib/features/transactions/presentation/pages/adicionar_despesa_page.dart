import 'package:finance/features/transactions/presentation/controllers/transacao_controller.dart';
import 'package:finance/core/money/money.dart';
import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/features/transactions/presentation/widgets/confirmation_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance/features/account/presentation/controllers/usuario_controller.dart';

class AdicionarDespesaPage extends StatefulWidget {
  const AdicionarDespesaPage({super.key});

  @override
  State<AdicionarDespesaPage> createState() => _AdicionarDespesaPageState();
}

class _AdicionarDespesaPageState extends State<AdicionarDespesaPage> {
  // Controladores para capturar o texto dos inputs reais
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  String selectedMethod = 'Crédito'; // Ajustado acento para bater com o banco
  String selectedCategory = 'Geral';
  static const categories = [
    'Geral',
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Lazer',
    'Educação',
    'Assinaturas',
    'Outros',
  ];
  bool isFamilyCard = false;
  String? selectedCardId;
  bool isInstallments = false;
  int installmentsCount = 1;
  DateTime dataLancamento = DateTime.now();
  bool _salvando = false;
  String? _erro;

  // Variáveis para cálculos dinâmicos na tela
  double valorTotalGasto = 0.0;
  double valorDaParcelaCalculada = 0.0;

  @override
  void initState() {
    super.initState();
    // Escuta as mudanças no campo de valor para recalcular o resumo dinamicamente
    _valorController.addListener(_atualizarValores);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  // Recalcula a matemática da tela sempre que o usuário digita um valor ou altera parcelas
  void _atualizarValores() {
    setState(() {
      valorTotalGasto = converterValorMonetario(_valorController.text);
      if (isInstallments && installmentsCount > 0) {
        final totalCentavos = valorEmCentavos(valorTotalGasto);
        final centavosBase = totalCentavos ~/ installmentsCount;
        final restoCentavos = totalCentavos % installmentsCount;
        valorDaParcelaCalculada = valorDeCentavos(
          centavosBase + (restoCentavos > 0 ? 1 : 0),
        );
      } else {
        valorDaParcelaCalculada = valorTotalGasto;
      }
    });
  }

  // Executa o salvamento de verdade no SQLite do celular
  Future<void> _confirmarELancarGasto() async {
    if (_salvando) return;
    if (valorTotalGasto <= 0 || _descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha a descrição e o valor.'),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    final valorSalvo = valorTotalGasto;
    final valorParcelaSalva = valorDaParcelaCalculada;
    try {
      await context.read<TransacaoController>().salvarGastoNoBanco(
        descricao: _descricaoController.text.trim(),
        valorTotal: valorSalvo,
        metodoPagamento: selectedMethod,
        cartaoId: selectedCardId,
        isCartaoFamiliar: isFamilyCard,
        isParcelado: isInstallments,
        totalParcelas: isInstallments ? installmentsCount : 1,
        categoria: selectedCategory,
        data: dataLancamento,
      );
    } catch (erro) {
      if (mounted) {
        setState(() {
          _salvando = false;
          _erro = 'Não foi possível salvar: $erro';
        });
      }
      return;
    }

    // Abre o seu modal visual de confirmação de sucesso
    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ConfirmationBottomSheet(
          valorParcela: valorParcelaSalva,
          valorTotal: valorSalvo,
        ),
      );

      // Limpa os campos após salvar com sucesso
      _descricaoController.clear();
      _valorController.clear();
      setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back),
        title: const Text('Lançar Gasto', style: TextStyle(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Valor do Gasto',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  // Campo numérico customizado para digitar o valor real
                  TextField(
                    controller: _valorController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      prefixText: 'R\$ ',
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            if (_erro != null) ...[
              const SizedBox(height: 12),
              Text(_erro!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 32),
            const Text('Descrição', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            // Input que captura o texto da descrição
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                hintText: 'Supermercado Familiar',
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Data do lançamento'),
                TextButton.icon(
                  onPressed: _selecionarData,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(
                    '${dataLancamento.day.toString().padLeft(2, '0')}/${dataLancamento.month.toString().padLeft(2, '0')}/${dataLancamento.year}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Método de Pagamento', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMethodButton('Crédito'),
                const SizedBox(width: 8),
                _buildMethodButton('Débito'),
                const SizedBox(width: 8),
                _buildMethodButton('PIX'),
              ],
            ),
            if (selectedMethod == 'Crédito') ...[
              const SizedBox(height: 16),
              _buildCardSelector(),
            ],
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => selectedCategory = value);
              },
            ),
            const SizedBox(height: 24),
            if (selectedMethod == 'Crédito' && selectedCardId != null)
              Text(
                isFamilyCard
                    ? 'Cartão de outra pessoa: este gasto aparecerá em A receber.'
                    : 'Cartão próprio.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            const SizedBox(height: 12),
            _buildSwitchTile('Parcelar Gasto?', null, isInstallments, (val) {
              setState(() => isInstallments = val);
              _atualizarValores();
            }),
            if (isInstallments) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Número de parcelas'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          onPressed: () {
                            if (installmentsCount > 1) {
                              setState(() => installmentsCount--);
                              _atualizarValores();
                            }
                          },
                        ),
                        Text(
                          '$installmentsCount x',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: () {
                            setState(() => installmentsCount++);
                            _atualizarValores();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            // Bloco de Resumo Dinâmico com valores reais calculados
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resumo do Lançamento',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    isInstallments
                        ? '$installmentsCount x de R\$ ${valorDaParcelaCalculada.toStringAsFixed(2).replaceAll('.', ',')}'
                        : 'À vista de R\$ ${valorTotalGasto.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Ao clicar, valida os dados e executa a persistência no SQLite
                onPressed: _salvando ? null : _confirmarELancarGasto,
                child: Text(
                  _salvando ? 'Salvando...' : 'Lançar Gasto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataLancamento,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data != null && mounted) {
      setState(() => dataLancamento = data);
    }
  }

  Widget _buildMethodButton(String method) {
    bool isSelected = selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMethod = method;
            if (method != 'Crédito') {
              selectedCardId = null;
              isFamilyCard = false;
            }
          });
          _atualizarValores();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppTheme.primaryColor)
                : null,
          ),
          child: Center(
            child: Text(
              method,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSelector() {
    final cartoes = context.watch<UsuarioController>().cartoes;
    if (cartoes.isEmpty) {
      return Text(
        'Cadastre um cartão no perfil para associá-lo a esta compra.',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: selectedCardId,
      decoration: const InputDecoration(labelText: 'Cartão da compra'),
      items: cartoes
          .map(
            (cartao) => DropdownMenuItem(
              value: cartao.id,
              child: Text('${cartao.nome} • **** ${cartao.finalNumero}'),
            ),
          )
          .toList(),
      onChanged: (valor) {
        final cartao = cartoes.where((item) => item.id == valor).firstOrNull;
        setState(() {
          selectedCardId = valor;
          isFamilyCard = cartao?.isFamiliar ?? false;
        });
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    String? subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
}
