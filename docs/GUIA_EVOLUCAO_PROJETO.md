# Guia para evoluir o projeto

## Regra de ouro

Toda funcionalidade deve seguir este caminho:

1. Desenhe o campo ou acao na tela.
2. Crie uma variavel de estado com tipo explicito.
3. Coloque a regra em um metodo pequeno e testavel.
4. Modele o dado em `data/models`.
5. Passe pelo repository. Hoje ele usa memória; no futuro poderá usar SQLite.
6. Recarregue o controller e notifique a interface.
7. Teste primeiro a regra, depois o widget e por fim o fluxo completo.

## Como investigar um bug

- `null`: procure quem produz o valor, quem o transporta e quem o le. Evite acessar estado privado de outra tela.
- Tela sem atualizar: confira se o widget usa `Consumer` ou `watch` e se o controller chama `notifyListeners`.
- Dados somem: confira o `insert`, a consulta e o `fromMap`; depois reinicie o app.
- Totais errados: confirme se o dashboard soma `valorParcela`, nao `valorTotal` de uma compra parcelada.
- Valor nao aparece: confira se o campo usa formato `3000`, `3000,50` ou `3.000,50`; o parser converte os formatos brasileiros e o controller cria uma linha por parcela.
- Erro apos mudar colunas: quando o SQLite for ativado, aumente a versao do banco e escreva uma migracao em `onUpgrade`.

## Proximas entregas recomendadas

1. Adicionar data escolhida pelo usuario e cartao selecionado ao modelo de transacao.
2. Criar uma tabela de receitas e calcular saldo.
3. Representar cada parcela em uma tabela mensal, caso seja necessario consultar vencimentos individualmente.
4. Permitir cadastrar faturas sem detalhar compras.
5. Adicionar categorias selecionaveis e agrupar o dashboard por categoria.
6. Criar testes unitarios para calculo de parcelas e totais.
7. Criar testes de widget para cadastrar uma despesa e encontra-la no historico.
8. So depois avaliar Repository, Riverpod ou outra abstracao. A arquitetura deve resolver uma necessidade real.

## Cuidados de negocio

- Valor deve ser maior que zero.
- Descricao deve ser obrigatoria.
- Parcelas devem ser no minimo 1.
- Valores monetarios exibidos usam virgula e os repositories atuais guardam objetos Dart em memoria.
- Compras de terceiros precisam de uma regra clara: entram no gasto pessoal, no comprometimento, ou apenas na fatura?
- Alteracoes de schema precisam preservar os dados existentes.

## Qualidade antes de publicar

```powershell
flutter analyze
flutter test
flutter build apk --release
```

## Quando integrar o SQLite

1. Estude `lib/core/database/database_helper.dart`.
2. Faça `TransacaoRepository` ler e salvar na tabela `transacoes`.
3. Faça `CartaoRepository` ler e salvar na tabela `cartoes`.
4. Inicialize o banco apenas em plataformas compatíveis.
5. Crie testes com banco em memória ou um datasource falso.
6. Execute `flutter analyze` e `flutter test` antes de remover a implementação em memória.

Nao coloque senhas, tokens, bancos exportados ou arquivos de build no repositorio. O armazenamento local nao substitui backup nem sincronizacao entre dispositivos.
