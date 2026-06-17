import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/name_setup_screen.dart';
import '../../features/onboarding/presentation/screens/salary_setup_screen.dart';
import '../../features/onboarding/presentation/screens/rule_setup_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/expenses/presentation/screens/add_expense_screen.dart';
import '../../features/expenses/domain/entities/expense_entity.dart';
import '../../features/debts/presentation/screens/debts_screen.dart';
import '../../features/debts/presentation/screens/add_debt_screen.dart';
import '../../features/debts/domain/entities/debt_entity.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/banks/presentation/screens/banks_screen.dart';
import '../../features/cards/presentation/screens/cards_screen.dart';
import '../../features/installments/presentation/screens/installments_screen.dart';
import '../../features/reserve/presentation/screens/reserve_screen.dart';
import '../../features/subscriptions/presentation/screens/subscriptions_screen.dart';
import '../../features/settings/presentation/screens/more_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AsyncValue<bool>>(hasUserProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) {
      final hasUserAsync = ref.read(hasUserProvider);
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');

      return hasUserAsync.when(
        loading: () => null,
        error: (_, _) => isOnboarding ? null : '/onboarding/name',
        data: (hasUser) {
          if (!hasUser && !isOnboarding) return '/onboarding/name';
          if (hasUser && isOnboarding) return '/home';
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/onboarding/name',
        builder: (_, _) => const NameSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/salary',
        builder: (_, _) => const SalarySetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/rule',
        builder: (_, _) => const RuleSetupScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            MainShell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (_, _) => const ExpensesScreen(),
          ),
          GoRoute(
            path: '/subscriptions',
            builder: (_, _) => const SubscriptionsScreen(),
          ),
          GoRoute(
            path: '/goals',
            builder: (_, _) => const GoalsScreen(),
          ),
          GoRoute(
            path: '/more',
            builder: (_, _) => const MoreScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/expenses/add',
        builder: (_, _) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: '/expenses/edit',
        builder: (_, state) =>
            AddExpenseScreen(expenseToEdit: state.extra as ExpenseEntity?),
      ),
      GoRoute(
        path: '/debts',
        builder: (_, _) => const DebtsScreen(),
      ),
      GoRoute(
        path: '/debts/add',
        builder: (_, _) => const AddDebtScreen(),
      ),
      GoRoute(
        path: '/debts/edit',
        builder: (_, state) =>
            AddDebtScreen(debtToEdit: state.extra as DebtEntity?),
      ),
      GoRoute(
        path: '/banks',
        builder: (_, _) => const BanksScreen(),
      ),
      GoRoute(
        path: '/cards',
        builder: (_, _) => const CardsScreen(),
      ),
      GoRoute(
        path: '/installments',
        builder: (_, _) => const InstallmentsScreen(),
      ),
      GoRoute(
        path: '/reserve',
        builder: (_, _) => const ReserveScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
  );
});

class MainShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({super.key, required this.child, required this.state});

  int _getCurrentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/subscriptions')) return 2;
    if (location.startsWith('/goals')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(state.matchedLocation);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A2634),
        selectedIndex: currentIndex,
        indicatorColor: const Color(0xFF00C896).withValues(alpha: 0.2),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/expenses');
              break;
            case 2:
              context.go('/subscriptions');
              break;
            case 3:
              context.go('/goals');
              break;
            case 4:
              context.go('/more');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(Icons.subscriptions_outlined),
            selectedIcon: Icon(Icons.subscriptions),
            label: 'Assinaturas',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Metas',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_outlined),
            selectedIcon: Icon(Icons.menu),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}
