# Integração SQLite com Flutter

## Visão geral

O aplicativo usa o SQLite como fonte local de verdade. O Flutter chama repositórios, os repositórios acessam o `DatabaseHelper` e os controllers notificam a interface com `ChangeNotifier`.

```text
Tela -> Controller -> Repository -> DatabaseHelper -> SQLite
```

Não existe servidor nesta versão. O login é local ao dispositivo: a senha nunca é salva em texto puro, mas este mecanismo não substitui autenticação de servidor para dados que precisem de segurança ou sincronização.

## Inicialização

`DatabaseHelper.instance` é um singleton. A propriedade `database` abre `meu_controle.db` uma única vez e compartilha a mesma `Future` enquanto a abertura está em andamento. Isso evita duas inicializações simultâneas quando mais de um controller começa no mesmo instante.

A abertura executa `PRAGMA foreign_keys = ON`, habilitando exclusão em cascata. O banco está na versão 3:

- `usuarios`: identidade, e-mail, hash da senha e flag da sessão ativa.
- `configuracoes_usuario`: preferências por usuário, com chave/valor.
- `cartoes`: cartões associados por `user_id`.
- `transacoes`: parcelas associadas por `user_id`.
- `gastos_fixos`: gastos recorrentes associados por `user_id`.

## Fluxo de cadastro

1. `UsuarioController.cadastrar` normaliza o e-mail e calcula o SHA-256 da senha.
2. `UsuarioRepository.criar` insere o usuário com `sessao_ativa = 1`.
3. O controller salva as preferências padrão e atualiza seu estado.
4. `notifyListeners` faz o `ControleAcesso` mostrar a tela principal.

O índice único `COLLATE NOCASE` impede duas contas com o mesmo e-mail, ignorando maiúsculas e minúsculas.

## Fluxo de login

1. O controller consulta `usuarios` pelo e-mail normalizado.
2. Calcula o hash da senha informada e compara com `senha_hash`.
3. Se falhar, nenhuma sessão é alterada e o método retorna `false`.
4. Se passar, uma transação desativa todas as sessões e ativa somente o usuário autenticado.
5. Preferências e cartões daquele usuário são recarregados.
6. A interface recebe a mudança por `notifyListeners`.

Ao iniciar o app, apenas um usuário com `sessao_ativa = 1` pode entrar automaticamente. A conta continua salva depois do logout; somente a sessão é encerrada.

## Dados e isolamento

Toda consulta de cartão, transação ou gasto fixo exige `usuarioId`. Ao salvar, o `user_id` é gravado junto do registro. Assim, trocar de conta não mistura dados no histórico nem no perfil.

As parcelas de uma compra são inseridas dentro de uma transação SQLite. Se uma inserção falhar, o conjunto não fica parcialmente salvo.

## Migração

Ao encontrar um banco antigo, `onUpgrade` cria as tabelas novas e adiciona `user_id` às tabelas antigas. A conta que existia nas chaves antigas do `SharedPreferences` é importada uma única vez para `usuarios`; a sessão legada também é preservada. Depois disso, cadastro, login, logout e preferências usam SQLite.

A versão do banco deve ser incrementada quando houver mudança estrutural. A migração correspondente deve ser adicionada em `_upgradeDB`, mantendo os blocos condicionais por versão.

## Responsabilidades

- `DatabaseHelper`: caminho, versão, criação, migrações e configuração do SQLite.
- `UsuarioRepository`: usuários, sessão e configurações.
- `CartaoRepository`: cartões filtrados por usuário.
- `TransacaoRepository`: transações e gastos fixos filtrados por usuário.
- Controllers: regras de tela, estado e chamadas aos repositórios.
- Páginas Flutter: validação de formulário e apresentação dos estados.

## Validação local

Na raiz do projeto:

```bash
flutter pub get
flutter analyze
flutter test
```

Para inspecionar o banco durante o desenvolvimento, use um inspetor SQLite compatível com a plataforma. Nunca registre `senha`, `senha_hash` ou credenciais em logs de produção.
