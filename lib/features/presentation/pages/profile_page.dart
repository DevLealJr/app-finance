import 'package:finance/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.surfaceColor,
                child: Text('LC', style: TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Text('Lucas Costa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('lucas.costa@email.com', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 32),
              _buildSection('Meus Cartões', [
                _buildCardItem('Cartão Principal', 'Nubank • **** 4521', Icons.credit_card, Colors.blue),
                _buildCardItem('Cartão Familiar', 'Itau • **** 7832', Icons.credit_card, Colors.purple),
              ]),
              const SizedBox(height: 24),
              _buildSection('Preferências', [
                _buildPreferenceToggle('Notificações de vencimento', true),
                _buildPreferenceToggle('Lembrete de lançamento diário', false),
                _buildPreferenceToggle('Modo responsável', true, subtitle: 'Exige lançamento individual de cada gasto'),
              ]),
              const SizedBox(height: 24),
              _buildSection('Resumo do Mês', [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Meta mensal', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text('R\$ 5.000,00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text('R\$ 4.287,50 de R\$ 5.000,00', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStat('Parcelas ativas', '3'),
                    const SizedBox(width: 32),
                    _buildStat('Cartões cadastrados', '2'),
                  ],
                ),
              ]),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {},
                child: const Text('Sair da conta', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCardItem(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceToggle(String title, bool value, {String? subtitle}) {
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
                  Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {},
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
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
