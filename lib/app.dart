import 'package:finance/features/transactions/presentation/controllers/transacao_controller.dart';
import 'package:finance/features/account/presentation/controllers/usuario_controller.dart';
import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/core/routes/rotas.dart';
import 'package:finance/features/account/presentation/pages/cadastro_page.dart';
import 'package:finance/features/account/presentation/pages/controle_acesso.dart';
import 'package:finance/features/account/presentation/pages/entrar_page.dart';
import 'package:finance/features/home/presentation/pages/tela_principal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeuControleApp extends StatelessWidget {
  const MeuControleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider cria UMA única instância de cada controller e a
    // disponibiliza pra qualquer tela abaixo na árvore. É isso que garante
    // que um gasto lançado em AddExpensePage apareça no Dashboard e no
    // Histórico sem precisar passar dado manualmente de tela em tela.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransacaoController()),
        ChangeNotifierProvider(create: (_) => UsuarioController()),
      ],
      child: MaterialApp(
        title: 'MeuControle',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: Rotas.inicial,
        routes: {
          Rotas.inicial: (_) => const ControleAcesso(),
          Rotas.login: (_) => const EntrarPage(),
          Rotas.cadastro: (_) => const CadastroPage(),
          Rotas.principal: (_) => const TelaPrincipal(),
        },
      ),
    );
  }
}
