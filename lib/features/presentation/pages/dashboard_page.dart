import 'package:finance/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildSummaryChart(),
              const SizedBox(height: 32),
              _buildBalanceSection(),
              const SizedBox(height: 32),
              _buildCategoriesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text('Agosto 2028', style: TextStyle(fontSize: 12)),
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryChart() {
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
                  value: 0.72,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '72%',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'GASTO',
                    style: TextStyle(fontSize: 8, color: AppTheme.textSecondary),
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
                  'R\$ 4.287,50',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Dentro do limite planejado',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Row(
      children: [
        _buildBalanceItem('Crédito', 'R\$ 3.340'),
        const SizedBox(width: 12),
        _buildBalanceItem('Débito', 'R\$ 547'),
        const SizedBox(width: 12),
        _buildBalanceItem('PIX', 'R\$ 400'),
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
            Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
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
          children: [
            _buildCategoryCard('Alimentação', 'R\$ 1.200', Icons.restaurant, Colors.orange),
            _buildCategoryCard('Transporte', 'R\$ 450', Icons.directions_bus, Colors.blue),
            _buildCategoryCard('Lazer', 'R\$ 680', Icons.wine_bar, Colors.red),
            _buildCategoryCard('Saúde', 'R\$ 320', Icons.bolt, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String value, IconData icon, Color color) {
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
              Text(title, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
