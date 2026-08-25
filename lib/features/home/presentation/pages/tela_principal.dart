import 'package:finance/features/transactions/presentation/pages/adicionar_despesa_page.dart';
import 'package:finance/features/transactions/presentation/pages/historico_page.dart';
import 'package:finance/features/transactions/presentation/pages/painel_page.dart';
import 'package:finance/features/account/presentation/pages/perfil_page.dart';
import 'package:finance/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:finance/features/transactions/presentation/controllers/transacao_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PainelPage(),
    const AdicionarDespesaPage(),
    const HistoricoPage(),
    const PerfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TransacaoController>().recarregarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
