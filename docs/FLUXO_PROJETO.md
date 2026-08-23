# Fluxo do projeto

## Entrada

`lib/main.dart` inicializa a localizacao do `intl` e chama `MeuControleApp`.

`lib/app.dart` cria o `MultiProvider`. Ele fornece uma instancia de `TransacaoController` e uma de `UsuarioController` para todas as telas.

`ControleAcesso` observa a sessao local. Enquanto carrega, mostra progresso; se houver sessao, mostra `TelaPrincipal`; caso contrario, mostra `EntrarPage`.

As rotas de autenticacao sao `/login` e `/cadastro`. O login tambem permite redefinir a senha localmente usando o e-mail cadastrado. Como nao existe backend, nao ha envio de e-mail; o usuario define a nova senha no proprio aparelho.

## Camadas atuais

- `features/account`: autenticação, sessão, preferências e cartões.
- `features/transactions`: despesas, parcelas, dashboard e histórico.
- `features/home`: composição da área principal e navegação inferior.
- `data/models`: estruturas persistidas no banco.
- `data/repositories`: acesso aos dados; as telas não acessam SQLite diretamente.
- `presentation/controllers`: estado e regras usadas pelas telas.
- `core/database`: configuração e migração do SQLite.
- `core/routes` e `core/theme`: rotas nomeadas e identidade visual.

O caminho de uma despesa e:

`AdicionarDespesaPage` -> `TransacaoController` -> `TransacaoRepository` -> `TransacaoModel` -> memória da aplicação.

Depois do insert, o controller chama `atualizarDashboardEHistorico`, recalcula os totais e executa `notifyListeners`. Dashboard e Historico usam `Consumer<TransacaoController>` e redesenham.

Uma compra parcelada cria uma linha por parcela em memória, com a mesma compra, `parcelaAtual` diferente e uma data mensal diferente. Uma compra a vista cria apenas uma linha.

## Variaveis importantes

- `valorTotalGasto`: total digitado na tela.
- `installmentsCount`: quantidade de parcelas escolhida.
- `valorDaParcelaCalculada`: `valorTotalGasto / installmentsCount` quando parcelado; caso contrario, e o proprio total.
- `totalGastoMes`: soma de `valorParcela` no mes selecionado.
- `totalCredito`, `totalDebito`, `totalPix`: totais por meio de pagamento.
- `totalComprometidoFuturo`: parcelas restantes de todas as compras.
- `transacoesFiltradas`: lista exibida no historico.

## Persistencia atual e proxima etapa

Por enquanto, despesas e cartões ficam somente em memória e são perdidos quando o aplicativo é encerrado. Os repositories já são o ponto correto para conectar o SQLite futuramente sem modificar as telas.

O arquivo `core/database/database_helper.dart` foi mantido como material de estudo. Ele mostra criação de tabelas, migração, conversão de booleans para `0/1` e datas ISO 8601, mas não é chamado pelo app atual.

A confirmacao recebe `valorParcela` e `valorTotal` pelo construtor. Nao existe leitura estatica de uma tela e nao existe valor ficticio no resumo.

Para diagnosticar um lançamento, confira o console por `[TRANSACAO]` e, no app, a mensagem exibida no botão. O botão fica em `Salvando...` durante a gravação.

## Autenticacao

`UsuarioController` salva nome, e-mail, hash SHA-256 da senha e sessao no `SharedPreferences`. Isso e autenticacao local, sem servidor e sem sincronizacao.
