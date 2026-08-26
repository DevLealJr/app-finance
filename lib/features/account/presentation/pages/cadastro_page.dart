import 'package:finance/features/account/presentation/controllers/usuario_controller.dart';
import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/core/routes/rotas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    setState(() => _erro = null);

    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      setState(() => _erro = 'Preencha nome, e-mail e senha.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _erro = 'Digite um e-mail válido.');
      return;
    }
    if (senha.length < 4) {
      setState(() => _erro = 'A senha precisa ter pelo menos 4 caracteres.');
      return;
    }
    if (senha != confirmarSenha) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }

    setState(() => _salvando = true);

    var cadastroConcluido = false;
    try {
      await context.read<UsuarioController>().cadastrar(
        nome: nome,
        email: email,
        senha: senha,
      );
      cadastroConcluido = true;
    } catch (erro) {
      if (mounted) {
        setState(() => _erro = erro.toString().replaceFirst('Bad state: ', ''));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }

    // O AuthGate (widget raiz) está observando isLoggedIn e já vai trocar
    // sozinho pra MainScreen assim que cadastrar() chamar notifyListeners().
    // Só precisamos fechar esta tela, que foi empilhada por cima dele.
    if (mounted && cadastroConcluido) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Criar conta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seus dados ficam só neste aparelho',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 32),
              _buildLabel('Nome'),
              TextField(
                controller: _nomeController,
                decoration: _inputDecoration('Como podemos te chamar'),
              ),
              const SizedBox(height: 16),
              _buildLabel('E-mail'),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('seuemail@exemplo.com'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Senha'),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: _inputDecoration('Mínimo 4 caracteres'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Confirmar senha'),
              TextField(
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: _inputDecoration('Repita a senha'),
                onSubmitted: (_) => _cadastrar(),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 16),
                Text(
                  _erro!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _cadastrar,
                  child: _salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Criar conta',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(Rotas.login),
                  child: Text(
                    'Já tenho uma conta',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
