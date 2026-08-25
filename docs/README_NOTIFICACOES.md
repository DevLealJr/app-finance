# Notificações locais

O Finance usa `flutter_local_notifications` para criar notificações no próprio aparelho. Não há servidor, Firebase ou custo de rede: os agendamentos continuam registrados pelo sistema mesmo quando o aplicativo está fechado.

## O que foi implementado

- **Lembrete diário**: todos os dias às 20:00, pedindo o registro dos gastos.
- **Notificação de vencimento**: no primeiro dia de cada mês às 09:00, lembrando a revisão dos vencimentos.
- **Permissão do sistema**: solicitada quando as preferências são sincronizadas.
- **Persistência da preferência**: os switches ficam no SQLite, associados ao usuário.
- **Cancelamento idempotente**: desligar um switch cancela o agendamento correspondente; ligar novamente não cria duplicatas.

## Fluxo técnico

```text
main.dart
  -> NotificationService.initialize()
  -> UsuarioController carrega preferências do SQLite
  -> NotificationService.synchronize()
  -> sistema operacional agenda ou cancela os avisos
```

O serviço usa IDs fixos para cada tipo de aviso. Antes de agendar, ele cancela esses IDs e recria apenas os avisos habilitados. O pacote `timezone` calcula o próximo horário como `TZDateTime`, evitando agendamento baseado em texto ou horário UTC incorreto.

## Onde alterar os horários

Os horários estão em `lib/core/notifications/notification_service.dart`:

- lembrete diário: `hour: 20`, `minute: 0`;
- aviso mensal: `9` no primeiro dia do mês.

O horário mensal pode ser alterado no `TZDateTime` de `_scheduleMonthly`.

## Android

A permissão `POST_NOTIFICATIONS` está declarada em `android/app/src/main/AndroidManifest.xml`. Em Android 13 ou superior, o usuário precisa aceitar a permissão em tempo de execução. Se recusar, o app continua funcionando, mas não exibe os avisos.

O canal `Financeiro` é criado automaticamente pelo plugin. Para mudar nome, descrição, importância ou som, altere `_details` no serviço. O ícone usado é o launcher existente em `@mipmap/ic_launcher`.

## iOS

A permissão de alerta, badge e som é solicitada pelo `IOSFlutterLocalNotificationsPlugin`. O pedido deve ser aceito pelo usuário para os agendamentos aparecerem. Testes no simulador podem ter comportamento diferente de um iPhone físico, especialmente em relação a entrega em segundo plano.

## Teste manual

1. Execute `flutter pub get`.
2. Instale o app em um dispositivo ou emulador.
3. Abra Perfil e habilite um dos switches de notificação.
4. Aceite a permissão do sistema.
5. Para testar rapidamente, altere temporariamente os horários no serviço para alguns minutos à frente.
6. Feche o app e aguarde o horário agendado.
7. Desabilite o switch e confirme que o aviso deixou de ser agendado.

Depois do teste, restaure os horários de produção antes de gerar o APK.

## Limitações importantes

- Notificações locais não sincronizam entre aparelhos.
- O sistema pode atrasar notificações em modo de economia de bateria.
- O lembrete diário não conhece automaticamente o conteúdo dos gastos; ele é um aviso geral.
- A notificação mensal é um resumo fixo. Para avisos por transação ou vencimento individual, será necessário adicionar data de vencimento e um ID de notificação para cada registro no SQLite.

## Validação

```bash
flutter analyze
flutter test
```
