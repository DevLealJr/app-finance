import 'package:finance/app.dart';
import 'package:finance/core/notifications/notification_service.dart';
import 'package:finance/update_service.dart'; // Ajuste o import do seu serviço
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await NotificationService.instance.initialize();

  runApp(const MeuControleApp());

  // Executa a checagem em segundo plano após o app abrir
  UpdateService.checkAndInstallUpdate();
}
