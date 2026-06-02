import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'core/theme/app_theme.dart';
import 'pages/auth/login_page.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/menu/menu_page.dart';
import 'pages/shift/shift_page.dart';
import 'pages/transaction/transaction_page.dart';
import 'pages/stock/stock_page.dart';
import 'pages/report/report_page.dart';
import 'pages/profile/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi sqflite_common_ffi untuk platform desktop (Windows/Linux/macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initializeDateFormatting('id_ID', null);
  runApp(const ShiftMateCafeApp());
}

class ShiftMateCafeApp extends StatelessWidget {
  const ShiftMateCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShiftMate Café',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/menu': (context) => const MenuPage(),
        '/shift': (context) => const ShiftPage(),
        '/transaction': (context) => const TransactionPage(),
        '/stock': (context) => const StockPage(),
        '/report': (context) => const ReportPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
