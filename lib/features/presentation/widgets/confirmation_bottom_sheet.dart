import 'package:finance/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  const ConfirmationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deseja somar ao último valor?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Detectamos um lançamento recente de mesmo valor e categoria.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 32),
          _buildRow('Total Atual', 'R\$ 4.287,50'),
          const SizedBox(height: 12),
          _buildRow('+ Novo Lançamento', 'R\$ 150,00', valueColor: AppTheme.primaryColor),
          const Divider(height: 32, color: Colors.white10),
          _buildRow('Novo Total Planejado', 'R\$ 4.437,50', isBold: true),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
