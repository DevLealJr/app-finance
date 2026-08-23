import 'package:finance/features/account/presentation/controllers/usuario_controller.dart';
import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/core/routes/rotas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntrarPage extends StatefulWidget {
  const EntrarPage({super.key});

  @override
  State<EntrarPage> createState() => _EntrarPageState();
}

class _EntrarPageState extends State<EntrarPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _entrando = false;
  String? _erro;
  String? _mensagem;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _erro = null;
      _mensagem = 'Verificando seus dados...';
      _entrando = true;
    });

    bool sucesso = false;
    try {
      sucesso = await context.read<UsuarioController>().login(
        email: _emailController.text,
        senha: _senhaController.text,
      );
    } catch (erro, stackTrace) {
      debugPrint('[AUTH][ERRO] Falha no login: $erro');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível concluir o login. Tente novamente.';
          _mensagem = null;
        });
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _entrando = false;
      _mensagem = sucesso ? 'Login autorizado.' : null;
    });

    if (!sucesso) {
      setState(() => _erro = 'E-mail ou senha incorretos.');
      // Não precisamos navegar em caso de sucesso: o AuthGate está
      // observando isLoggedIn no controller e troca de tela sozinho.
    }
  }

  Future<void> _recuperarSenha() async {
    final emailController = TextEditingController(text: _emailController.text);
    final novaSenhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();
    String? erro;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Redefinir senha'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seu usuário é o e-mail cadastrado: ${context.read<UsuarioController>().email}. Informe-o e crie uma nova senha.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('E-mail cadastrado'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: novaSenhaController,
                  obscureText: true,
                  decoration: _inputDecoration('Nova senha'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmarSenhaController,
                  obscureText: true,
                  decoration: _inputDecoration('Confirmar nova senha'),
                ),
                if (erro != null) ...[
                  const SizedBox(height: 12),
                  Text(erro!, style: const TextStyle(color: Colors.redAccent)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final novaSenha = novaSenhaController.text;
                if (emailController.text.trim().toLowerCase() !=
                    context
                        .read<UsuarioController>()
                        .email
                        .trim()
                        .toLowerCase()) {
                  setDialogState(() => erro = 'E-mail não encontrado.');
                  return;
                }
                if (novaSenha.length < 4) {
                  setDialogState(
                    () => erro = 'A senha precisa ter pelo menos 4 caracteres.',
                  );
                  return;
                }
                if (novaSenha != confirmarSenhaController.text) {
                  setDialogState(() => erro = 'As senhas não coincidem.');
                  return;
                }
                try {
                  await context.read<UsuarioController>().redefinirSenha(
                    novaSenha,
                  );
                } catch (exception, stackTrace) {
                  debugPrint(
                    '[AUTH][ERRO] Falha ao redefinir senha: $exception',
                  );
                  debugPrintStack(stackTrace: stackTrace);
                  setDialogState(
                    () => erro = 'Não foi possível salvar a nova senha.',
                  );
                  return;
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (mounted) {
                  setState(
                    () => _erro = 'Senha alterada. Entre com a nova senha.',
                  );
                }
              },
              child: const Text('Salvar senha'),
            ),
          ],
        ),
      ),
    );
    emailController.dispose();
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contaCriada = context.watch<UsuarioController>().contaCriada;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text(
                'MeuControle',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entre na sua conta',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 48),
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
                decoration: _inputDecoration('Sua senha'),
                onSubmitted: (_) => _entrar(),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 16),
                Text(
                  _erro!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
              if (_mensagem != null) ...[
                const SizedBox(height: 16),
                Text(
                  _mensagem!,
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _entrando ? null : _entrar,
                  child: _entrando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              if (contaCriada)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _entrando ? null : _recuperarSenha,
                    child: const Text('Esqueci meu usuário ou senha'),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(Rotas.cadastro),
                  child: Text(
                    contaCriada
                        ? 'Não tem conta? Criar uma nova'
                        : 'Criar minha conta',
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
