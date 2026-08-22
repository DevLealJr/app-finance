import 'package:finance/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Agosto', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todos', isSelected: true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Crédito'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Débito'),
                    const SizedBox(width: 8),
                    _buildFilterChip('PIX'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'ÚLTIMOS LANÇAMENTOS',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildTransactionItem('Supermercado', 'Crédito • Parcelas 1/2', '-R\$ 320,00', Icons.restaurant, Colors.orange),
                    _buildTransactionItem('Uber', 'Débito • Transporte', '-R\$ 28,50', Icons.directions_car, Colors.blue),
                    _buildTransactionItem('Farmácia', 'PIX • Saúde', '-R\$ 89,00', Icons.bolt, Colors.green),
                    _buildTransactionItem('Netflix', 'Crédito • Lazer', '-R\$ 55,90', Icons.wine_bar, Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
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
    );
  }

  Widget _buildTransactionItem(String title, String subtitle, String value, IconData icon, Color color) {
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
