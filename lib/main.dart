import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/main_layout.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/transaction_detail_screen.dart';
import 'screens/budgeting_limits_screen.dart';
import 'screens/manage_categories_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: const LedgerlyApp(),
    ),
  );
}

class LedgerlyApp extends StatelessWidget {
  const LedgerlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledgerly',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Immersive dark mode by default
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const MainLayout(),
        '/add-transaction': (context) => const AddTransactionScreen(),
        '/transaction-detail': (context) => const TransactionDetailScreen(),
        '/budgeting-limits': (context) => const BudgetingLimitsScreen(),
        '/manage-categories': (context) => const ManageCategoriesScreen(),
      },
    );
  }
}
