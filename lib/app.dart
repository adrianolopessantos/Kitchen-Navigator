import 'package:flutter/material.dart';
import 'core/state/app_scope.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/pantry/pantry_screen.dart';
import 'features/planner/planner_screen.dart';
import 'features/recipes/recipes_screen.dart';
import 'features/shopping/shopping_screen.dart';

class KitchenNavigatorApp extends StatefulWidget {
  const KitchenNavigatorApp({super.key});

  @override
  State<KitchenNavigatorApp> createState() => _KitchenNavigatorAppState();
}

class _KitchenNavigatorAppState extends State<KitchenNavigatorApp> {
  final state = AppState();

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Kitchen Navigator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const _AppLoadingGate(),
      ),
    );
  }
}


class _AppLoadingGate extends StatelessWidget {
  const _AppLoadingGate();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    if (!state.dataLoaded) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 14),
                Text('Loading your kitchen data...'),
              ],
            ),
          ),
        ),
      );
    }

    return const AppShell();
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  void openTab(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        openPlanner: () => openTab(3),
        openPantry: () => openTab(1),
        openShopping: () => openTab(4),
      ),
      const PantryScreen(),
      const RecipesScreen(),
      const PlannerScreen(),
      const ShoppingScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: openTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Pantry',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
        ],
      ),
      ),
    );
  }
}
