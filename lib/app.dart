import 'package:flutter/material.dart';
import 'core/state/app_scope.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/pantry/pantry_screen.dart';
import 'features/planner/planner_screen.dart';
import 'features/recipes/recipes_screen.dart';
import 'features/shopping/shopping_screen.dart';
import 'features/family/household_setup_screen.dart';

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
        theme: AppTheme.light(),
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
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BrandMark(),
                  SizedBox(height: 20),
                  Text(
                    'Kitchen Navigator',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your guide from pantry to plate.',
                    style: TextStyle(
                      color: AppColors.muted,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!state.householdSetupComplete) {
      return const HouseholdSetupScreen();
    }

    return const AppShell();
  }
}


class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'assets/images/kitchen_navigator_icon.png',
          fit: BoxFit.cover,
        ),
      ),
    );
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
      PlannerScreen(openShopping: () => openTab(4)),
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
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, -2),
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
