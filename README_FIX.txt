Kitchen Navigator V12 Beta 1.3 - Dashboard V11 Sync Test Fix

Cause:
The old Version 11 dashboard regression test required:
  state.estimatedMonthlyPlanShoppingTotal
  state.householdProfile.monthlyBudget

Version 12 now uses the weekly shopping calculation directly:
  state.estimatedShoppingTotalForWeek
  state.weeklyShoppingBudget

and exposes deeper analysis through:
  openInsights(context)

Fix:
Updates only the stale regression test. No application code changes.

Install:
1. Extract ZIP.
2. Copy the test folder into:
   C:\Projects\KitchenNavigator
3. Replace the existing test file.
4. Run:
   C:\src\flutter\bin\flutter.bat test test\dashboard_v11_sync_test.dart
5. If it passes:
   C:\src\flutter\bin\flutter.bat test
