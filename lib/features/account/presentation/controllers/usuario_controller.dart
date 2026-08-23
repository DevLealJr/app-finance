import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:finance/features/account/data/models/usuario_model.dart';
import 'package:finance/features/account/data/repositories/cartao_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _senhaHash = "";
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
  UsuarioController() {
    carregarDadosDoDispositivo();
    carregarCartoes();
  }

  String _hash(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }

  // 1. FUNÇÃO QUE LÊ OS DADOS SALVOS NO CELULAR
  Future<void> carregarDadosDoDispositivo() async {
    try {
      debugPrint('[AUTH] Iniciando leitura dos dados locais.');
      final prefs = await SharedPreferences.getInstance();

      // Ler os valores salvos. Se for a 1ª vez e estiver vazio, fica em branco
      // mesmo — sem usuário fictício de demonstração.
      nome = prefs.getString('user_nome') ?? "";
      email = prefs.getString('user_email') ?? "";
      _senhaHash = prefs.getString('user_senha_hash') ?? "";
      contaCriada = _senhaHash.isNotEmpty;
      // A sessão só continua "logada" se a última ação tiver sido um login
      // bem-sucedido (ou cadastro) e a pessoa não tiver saído depois.
      isLoggedIn = contaCriada && (prefs.getBool('sessao_ativa') ?? false);

      notificacaoVencimento = prefs.getBool('pref_vencimento') ?? true;
      lembreteDiario = prefs.getBool('pref_lembrete') ?? false;
      modoResponsavel = prefs.getBool('pref_responsavel') ?? true;
      metaMensal =
          prefs.getDouble(
            'meta_mensal_${DateTime.now().year}_${DateTime.now().month}',
          ) ??
          prefs.getDouble('meta_mensal') ??
          5000.00;

      carregandoSessao = false;
      // Avisa a tela ProfilePage/AuthGate para se desenhar com os dados reais recuperados
      debugPrint(
        '[AUTH] Sessão carregada. contaCriada=$contaCriada, isLoggedIn=$isLoggedIn',
      );
      notifyListeners();
    } catch (erro, stackTrace) {
      debugPrint('[AUTH][ERRO] Falha ao carregar sessão: $erro');
      debugPrintStack(stackTrace: stackTrace);
      carregandoSessao = false;
      notifyListeners();
    }
  }

  // 2. CRIA A CONTA LOCAL (usado na tela de Cadastro)
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    debugPrint('[AUTH] Cadastrando usuário: ${email.trim()}');
    final prefs = await SharedPreferences.getInstance();

    this.nome = nome.trim();
    this.email = email.trim();
    _senhaHash = _hash(senha);
    contaCriada = true;
    isLoggedIn = true;

    await prefs.setString('user_nome', this.nome);
    await prefs.setString('user_email', this.email);
    await prefs.setString('user_senha_hash', _senhaHash);
    await prefs.setBool('sessao_ativa', true);

    debugPrint('[AUTH] Cadastro concluído. Sessão autorizada.');
    notifyListeners();
  }

  // 3. CONFERE E-MAIL + SENHA CONTRA O QUE ESTÁ SALVO (usado na tela de Login)
  // Retorna true se conseguiu entrar, false se e-mail/senha não batem.
  Future<bool> login({required String email, required String senha}) async {
    debugPrint('[AUTH] Tentativa de login: ${email.trim()}');
    final bool emailConfere =
        email.trim().toLowerCase() == this.email.trim().toLowerCase();
    final bool senhaConfere = _hash(senha) == _senhaHash;

    if (!emailConfere || !senhaConfere) {
      debugPrint('[AUTH] Login recusado: credenciais inválidas.');
      return false;
    }

    isLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sessao_ativa', true);
    debugPrint('[AUTH] Login autorizado. Sessão salva como ativa.');
    notifyListeners();
    return true;
  }

  Future<void> redefinirSenha(String novaSenha) async {
    debugPrint('[AUTH] Iniciando redefinição de senha.');
    _senhaHash = _hash(novaSenha);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_senha_hash', _senhaHash);
    debugPrint('[AUTH] Senha redefinida com sucesso.');
  }

  // 4. FUNÇÃO QUE SALVA A ALTERAÇÃO DO SWITCH DE NOTIFICAÇÃO
  Future<void> alternarNotificacao(bool valor) async {
    notificacaoVencimento = valor;
    notifyListeners(); // Atualiza a tela imediatamente para o usuário ver o switch mudar

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'pref_vencimento',
      valor,
    ); // Salva no armazenamento local
  }

  // 5. FUNÇÃO QUE SALVA A ALTERAÇÃO DO SWITCH DE LEMBRETE
  Future<void> alternarLembrete(bool valor) async {
    lembreteDiario = valor;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_lembrete', valor);
  }

  // 6. FUNÇÃO QUE SALVA A ALTERAÇÃO DO SWITCH DE MODO RESPONSÁVEL
  Future<void> alternarModoResponsavel(bool valor) async {
    modoResponsavel = valor;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_responsavel', valor);
  }

  // 7. FUNÇÃO PARA ATUALIZAR A META MENSAL (Caso você crie um campo de edição)
  Future<void> atualizarMetaMensal(double novaMeta) async {
    metaMensal = novaMeta;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('meta_mensal', novaMeta);
  }

  Future<void> carregarMetaDoPeriodo(int mes, int ano) async {
    final prefs = await SharedPreferences.getInstance();
    metaMensal =
        prefs.getDouble('meta_mensal_${ano}_$mes') ??
        prefs.getDouble('meta_mensal') ??
        5000.0;
    notifyListeners();
  }

  Future<void> salvarMetaDoPeriodo({
    required int mes,
    required int ano,
    required double valor,
  }) async {
    metaMensal = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('meta_mensal_${ano}_$mes', valor);
    await prefs.setDouble('meta_mensal', valor);
    notifyListeners();
  }

  // 8. ENCERRA A SESSÃO (a conta continua existindo, dá pra logar de novo).
  // Note que isso é diferente de apagar a conta: nome, e-mail, senha e os
  // gastos no SQLite continuam guardados no aparelho.
  Future<void> deslogar() async {
    isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sessao_ativa', false);
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
    await _cartaoRepository.salvar(cartao);
    await carregarCartoes();
  }

  Future<void> carregarCartoes() async {
    cartoes = await _cartaoRepository.listarTodos();
    cartoesCadastrados = cartoes.length;
    notifyListeners();
  }
}
