import 'package:finance/features/presentation/pages/add_expense_page.dart';
import 'package:finance/features/presentation/pages/dashboard_page.dart';
import 'package:finance/features/presentation/pages/history_page.dart';
import 'package:finance/features/presentation/pages/profile_page.dart';
import 'package:finance/features/presentation/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const AddExpensePage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
