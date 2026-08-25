import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  static const _dailyId = 1001;
  static const _monthlyId = 1002;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    timezone_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidResult = await android?.requestNotificationsPermission();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosResult = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return androidResult ?? iosResult ?? true;
  }

  Future<void> synchronize({
    required bool dueDateEnabled,
    required bool dailyReminderEnabled,
    int dailyHour = 20,
    int dailyMinute = 0,
    int monthlyHour = 9,
    int monthlyMinute = 0,
  }) async {
    await initialize();
    await _plugin.cancel(id: _dailyId);
    await _plugin.cancel(id: _monthlyId);
    if (!await requestPermission()) return;

    if (dailyReminderEnabled) {
      await _scheduleDaily(
        id: _dailyId,
        title: 'Lembrete financeiro',
        body: 'Reserve um minuto para registrar seus gastos de hoje.',
        hour: dailyHour,
        minute: dailyMinute,
      );
    }
    if (dueDateEnabled) {
      await _scheduleMonthly(hour: monthlyHour, minute: monthlyMinute);
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = timezone.TZDateTime.now(timezone.local);
    var next = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: next,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleMonthly({
    required int hour,
    required int minute,
  }) async {
    final now = timezone.TZDateTime.now(timezone.local);
    var next = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      1,
      hour,
      minute,
    );
    if (!next.isAfter(now)) {
      next = timezone.TZDateTime(timezone.local, now.year, now.month + 1, 1, 9);
    }
    await _plugin.zonedSchedule(
      id: _monthlyId,
      title: 'Resumo do mês',
      body: 'Confira seus vencimentos e organize o orçamento deste mês.',
      scheduledDate: next,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      'financeiro',
      'Financeiro',
      channelDescription: 'Lembretes e avisos do controle financeiro',
    ),
    iOS: DarwinNotificationDetails(),
  );
}
