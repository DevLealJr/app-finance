import 'package:finance/core/theme/app_theme.dart';
import 'package:finance/features/presentation/pages/main_screen.dart';
import 'package:flutter/material.dart';

class MeuControleApp extends StatelessWidget {
  const MeuControleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeuControle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
