import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/features/presentation/widgets/confirmation_bottom_sheet.dart';
import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  String selectedMethod = 'Credito';
  bool isFamilyCard = true;
  bool isInstallments = true;
  int installmentsCount = 3;

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
                  Text('Valor do Gasto', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ 450,00',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Descrição', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
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
            const SizedBox(height: 24),
            _buildSwitchTile(
              'Cartão Familiar',
              'Cobrar do limite compartilhado',
              isFamilyCard,
              (val) => setState(() => isFamilyCard = val),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Parcelar Gasto?',
              null,
              isInstallments,
              (val) => setState(() => isInstallments = val),
            ),
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
                          onPressed: () => setState(() => installmentsCount > 1 ? installmentsCount-- : null),
                        ),
                        Text('$installmentsCount x', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: () => setState(() => installmentsCount++),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Resumo do Lançamento', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                  Text('$installmentsCount x de R\$ 150,00', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ConfirmationBottomSheet(),
                  );
                },
                child: const Text('Lançar Gasto', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodButton(String method) {
    bool isSelected = selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: AppTheme.primaryColor) : null,
          ),
          child: Center(
            child: Text(
              method,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String? subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (subtitle != null)
              Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
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
