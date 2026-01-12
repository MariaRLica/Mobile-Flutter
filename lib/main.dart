import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/expense_provider.dart';
import 'providers/user_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/about_screen.dart';
import 'screens/api_resources_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userProv = UserProvider();
  await userProv.loadFromPrefs(); // opcional, já que a tela também chama load
  runApp(
    ChangeNotifierProvider<UserProvider>.value(
      value: userProv,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadFromPrefs()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..load()),
      ],
      child: MaterialApp(
        title: 'Controle de Despesas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        initialRoute: '/',
        routes: {
          '/resources': (context) => const ApiResourcesScreen(),
          '/': (context) => const DashboardScreen(),
          '/expenses': (context) => const ExpensesScreen(),
          '/budget': (context) => const BudgetScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/about': (context) => const AboutScreen(),
        },
      ),
    );
  }
}
