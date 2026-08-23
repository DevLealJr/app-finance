# Guia de execucao Flutter

## Preparar o ambiente

1. Instale Flutter e Android Studio.
2. No terminal, confirme o ambiente:

```powershell
flutter doctor
flutter devices
```

3. Na raiz do projeto, baixe as dependencias:

```powershell
flutter pub get
```

## Executar

```powershell
flutter run
```

Para escolher um dispositivo:

```powershell
flutter devices
flutter run -d <id-do-dispositivo>
```

O fluxo atual não depende de banco e pode ser testado em qualquer dispositivo Flutter. Despesas e cartões são temporários nesta etapa.

Durante a execucao:

- `r` faz hot reload e preserva o estado da tela.
- `R` faz hot restart e reinicia o estado Dart.
- `q` encerra a execucao.

No VS Code, `F5` inicia o debug e `Ctrl+F5` executa sem debug.

## Validar

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Use `flutter clean` somente quando houver cache de build problemático; depois execute `flutter pub get` novamente.

## Banco de estudo

O SQLite não é inicializado pelo app neste momento. O arquivo `lib/core/database/database_helper.dart` existe para estudo e será conectado quando você entender abertura de conexão, tabelas, `insert`, `query`, migrações e testes.

## Estrutura do código

O código da aplicação está organizado por funcionalidade em `lib/features`. Cada funcionalidade separa `data` (modelos e repositórios), `presentation/controllers` (estado) e `presentation/pages` (interface). A tela não deve chamar `sqflite` diretamente; altere o repositório quando a persistência mudar.

## Fluxo manual de teste

1. Cadastre uma conta local e entre.
2. Abra `Adicionar despesa`.
3. Informe descrição `Notebook`, valor `3000`, crédito e 10 parcelas.
4. Confirme se o resumo mostra `10 x de R$ 300,00`.
5. Salve e confira o histórico e o painel.
6. Feche e abra o app e observe que despesas/cartões temporários são reiniciados; o login continua salvo no `SharedPreferences`.

## Diagnosticar um lançamento

Durante o salvamento, o botao mostra `Salvando...`. No console, procure:

```text
[TRANSACAO] Salvando "Notebook": total=3000.0, parcelas=10
[TRANSACAO] 10 parcela(s) salvas com sucesso.
```

Se aparecer `Não foi possível salvar`, a mensagem da tela contém o erro devolvido pelo banco. Confira também se o valor foi digitado como `3000`, `3000,50` ou `3.000,50`.
