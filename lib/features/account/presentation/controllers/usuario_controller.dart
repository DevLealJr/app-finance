import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:finance/features/account/data/models/usuario_model.dart';
import 'package:finance/features/account/data/repositories/cartao_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/features/account/data/repositories/usuario_repository.dart';

class UsuarioController extends ChangeNotifier {
  // Dados de estado que a tela vai ler
  String nome = "";
  String email = "";
  bool notificacaoVencimento = true;
  bool lembreteDiario = false;
  bool modoResponsavel = true;
  double metaMensal = 0.0;

  // --- Autenticação local ---
  // Importante: este app NÃO tem servidor. "Login" aqui só confere se a
  // senha digitada bate com o hash salvo neste aparelho. Não existe
  // recuperação de senha por e-mail nem sincronização entre dispositivos.
  String _senhaHash = '';
  String? _usuarioId;
  bool contaCriada = false; // já existe uma conta cadastrada neste aparelho?
  bool isLoggedIn = false; // sessão ativa agora?
  bool carregandoSessao =
      true; // true enquanto lê o SharedPreferences pela 1ª vez

  // Variáveis calculadas que virão do controller de transações futuramente
  double totalGastoMes = 0.0;
  int parcelasAtivas = 0;
  int cartoesCadastrados = 0;

  // Lista de cartões mantida em memória enquanto o banco ainda não foi integrado.
  List<CartaoModel> cartoes = [];
  final CartaoRepository _cartaoRepository = CartaoRepository();

  // O construtor chama automaticamente a leitura do banco local ao ser iniciado
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  UsuarioController() {
    _inicializar();
  }

  String _hash(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }

  Future<void> _inicializar() async {
    try {
      final usuario = await _usuarioRepository.usuarioAtual();
      final primeiroUsuario = usuario ?? await _migrarOuLerPrimeiroUsuario();
      if (primeiroUsuario != null) {
        _aplicarUsuario(primeiroUsuario);
        final configuracoes = await _usuarioRepository.listarConfiguracoes(
          _usuarioId!,
        );
        _aplicarConfiguracoes(configuracoes);
        isLoggedIn = usuario != null || primeiroUsuario['sessao_ativa'] == 1;
      }
      contaCriada = await _usuarioRepository.existeConta();
      await carregarCartoes();

      carregandoSessao = false;
      notifyListeners();
    } catch (erro, stackTrace) {
      debugPrint('[AUTH][ERRO] Falha ao carregar sessão: $erro');
      debugPrintStack(stackTrace: stackTrace);
      carregandoSessao = false;
      notifyListeners();
    }
  }

  Future<Map<String, Object?>?> _migrarOuLerPrimeiroUsuario() async {
    final existente = await _usuarioRepository.primeiroUsuario();
    if (existente != null) return existente;

    final prefs = await SharedPreferences.getInstance();
    final senhaHash = prefs.getString('user_senha_hash');
    final emailLegado = prefs.getString('user_email');
    if (senhaHash == null ||
        emailLegado == null ||
        emailLegado.trim().isEmpty) {
      return null;
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _usuarioRepository.criar(
      id: id,
      nome: prefs.getString('user_nome') ?? '',
      email: emailLegado,
      senhaHash: senhaHash,
    );
    if (prefs.getBool('sessao_ativa') != true) {
      await _usuarioRepository.encerrarSessoes();
    }
    return await _usuarioRepository.primeiroUsuario();
  }

  void _aplicarUsuario(Map<String, Object?> usuario) {
    _usuarioId = usuario['id'] as String;
    nome = usuario['nome'] as String;
    email = usuario['email'] as String;
    _senhaHash = usuario['senha_hash'] as String;
  }

  void _aplicarConfiguracoes(Map<String, String> configuracoes) {
    notificacaoVencimento = configuracoes['pref_vencimento'] != 'false';
    lembreteDiario = configuracoes['pref_lembrete'] == 'true';
    modoResponsavel = configuracoes['pref_responsavel'] != 'false';
    metaMensal = double.tryParse(configuracoes['meta_mensal'] ?? '') ?? 5000;
  }

  Future<void> _salvarConfiguracao(String chave, String valor) async {
    if (_usuarioId != null) {
      await _usuarioRepository.salvarConfiguracao(_usuarioId!, chave, valor);
    }
  }

  // 2. CRIA A CONTA LOCAL (usado na tela de Cadastro)
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    debugPrint('[AUTH] Cadastrando usuário: ${email.trim()}');
    this.nome = nome.trim();
    this.email = email.trim();
    _senhaHash = _hash(senha);
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _usuarioRepository.criar(
      id: id,
      nome: this.nome,
      email: this.email,
      senhaHash: _senhaHash,
    );
    _usuarioId = id;
    contaCriada = true;
    isLoggedIn = true;
    metaMensal = 5000.0;
    await _salvarConfiguracao(
      'pref_vencimento',
      notificacaoVencimento.toString(),
    );
    await _salvarConfiguracao('pref_lembrete', lembreteDiario.toString());
    await _salvarConfiguracao('pref_responsavel', modoResponsavel.toString());
    await _salvarConfiguracao('meta_mensal', '5000.0');
    await carregarCartoes();

    debugPrint('[AUTH] Cadastro concluído. Sessão autorizada.');
    notifyListeners();
  }

  // 3. CONFERE E-MAIL + SENHA CONTRA O QUE ESTÁ SALVO (usado na tela de Login)
  // Retorna true se conseguiu entrar, false se e-mail/senha não batem.
  Future<bool> login({required String email, required String senha}) async {
    debugPrint('[AUTH] Tentativa de login: ${email.trim()}');
    final usuario = await _usuarioRepository.buscarPorEmail(email);
    if (usuario == null || _hash(senha) != usuario['senha_hash']) {
      debugPrint('[AUTH] Login recusado: credenciais inválidas.');
      return false;
    }

    _aplicarUsuario(usuario);
    await _usuarioRepository.ativarSessao(_usuarioId!);
    _aplicarConfiguracoes(
      await _usuarioRepository.listarConfiguracoes(_usuarioId!),
    );
    await carregarCartoes();
    isLoggedIn = true;
    debugPrint('[AUTH] Login autorizado. Sessão salva como ativa.');
    notifyListeners();
    return true;
  }

  Future<void> redefinirSenha(String novaSenha) async {
    debugPrint('[AUTH] Iniciando redefinição de senha.');
    _senhaHash = _hash(novaSenha);
    if (_usuarioId == null) return;
    await _usuarioRepository.atualizarSenha(_usuarioId!, _senhaHash);
    debugPrint('[AUTH] Senha redefinida com sucesso.');
  }

  // 4. FUNÇÃO QUE SALVA A ALTERAÇÃO DO SWITCH DE NOTIFICAÇÃO
  Future<void> alternarNotificacao(bool valor) async {
    notificacaoVencimento = valor;
    notifyListeners(); // Atualiza a tela imediatamente para o usuário ver o switch mudar

    await _salvarConfiguracao('pref_vencimento', valor.toString());
  }

  // 5. FUNÇÃO QUE SALVA A ALTERAÇÃO DO SWITCH DE LEMBRETE
  Future<void> alternarLembrete(bool valor) async {
    lembreteDiario = valor;
    notifyListeners();

    await _salvarConfiguracao('pref_lembrete', valor.toString());
  }

  // 6. FUNÇÃO QUE SALVA A ALTERAÇÃO DO SWITCH DE MODO RESPONSÁVEL
  Future<void> alternarModoResponsavel(bool valor) async {
    modoResponsavel = valor;
    notifyListeners();

    await _salvarConfiguracao('pref_responsavel', valor.toString());
  }

  // 7. FUNÇÃO PARA ATUALIZAR A META MENSAL (Caso você crie um campo de edição)
  Future<void> atualizarMetaMensal(double novaMeta) async {
    metaMensal = novaMeta;
    notifyListeners();

    await _salvarConfiguracao('meta_mensal', novaMeta.toString());
  }

  Future<void> carregarMetaDoPeriodo(int mes, int ano) async {
    if (_usuarioId != null) {
      final configuracoes = await _usuarioRepository.listarConfiguracoes(
        _usuarioId!,
      );
      metaMensal =
          double.tryParse(configuracoes['meta_mensal_${ano}_$mes'] ?? '') ??
          double.tryParse(configuracoes['meta_mensal'] ?? '') ??
          5000.0;
    }
    notifyListeners();
  }

  Future<void> salvarMetaDoPeriodo({
    required int mes,
    required int ano,
    required double valor,
  }) async {
    metaMensal = valor;
    await _salvarConfiguracao('meta_mensal_${ano}_$mes', valor.toString());
    await _salvarConfiguracao('meta_mensal', valor.toString());
    notifyListeners();
  }

  // 8. ENCERRA A SESSÃO (a conta continua existindo, dá pra logar de novo).
  // Note que isso é diferente de apagar a conta: nome, e-mail, senha e os
  // gastos no SQLite continuam guardados no aparelho.
  Future<void> deslogar() async {
    isLoggedIn = false;
    await _usuarioRepository.encerrarSessoes();
    _usuarioId = null;
    cartoes = [];
    cartoesCadastrados = 0;
    notifyListeners();
  }

  // Grava um cartão real digitado pelo usuário (substitui os cartões
  // fictícios que existiam antes) e recarrega a lista.
  Future<void> adicionarCartao({
    required String nome,
    required String finalNumero,
    required String bandeira,
    required bool isFamiliar,
  }) async {
    final cartao = CartaoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      finalNumero: finalNumero,
      bandeira: bandeira,
      isFamiliar: isFamiliar,
    );
    if (_usuarioId == null) return;
    await _cartaoRepository.salvar(cartao, usuarioId: _usuarioId!);
    await carregarCartoes();
  }

  Future<void> carregarCartoes() async {
    if (_usuarioId == null) {
      cartoes = [];
      cartoesCadastrados = 0;
      return;
    }
    cartoes = await _cartaoRepository.listarTodos(usuarioId: _usuarioId!);
    cartoesCadastrados = cartoes.length;
    notifyListeners();
  }
}
