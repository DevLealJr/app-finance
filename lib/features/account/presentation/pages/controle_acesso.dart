import 'package:finance/features/account/presentation/controllers/usuario_controller.dart';
import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/features/account/presentation/pages/cadastro_page.dart';
import 'package:finance/features/account/presentation/pages/entrar_page.dart';
import 'package:finance/features/home/presentation/pages/tela_principal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControleAcesso extends StatelessWidget {
  const ControleAcesso({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarioController = context.watch<UsuarioController>();

    if (usuarioController.carregandoSessao) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              SizedBox(height: 16),
              Text(
                'Carregando seus dados...',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (usuarioController.isLoggedIn) {
      return const TelaPrincipal();
    }

    return usuarioController.contaCriada
        ? const EntrarPage()
        : const CadastroPage();
  }
}
