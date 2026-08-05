Kitchen Navigator v11.0 Beta 1 - Dashboard Live Data Sync Fix

Fixes:
- Main-page Shopping card now uses the selected Version 11 shopping week
- Purchased products are excluded from the remaining count
- Shopping estimate updates from the monthly plan
- Budget card shows current weekly estimate versus weekly budget
- Budget note shows monthly estimate versus household monthly budget
- Planner card uses today's Version 11 monthly-plan entries
- Hero shopping count uses live remaining products
- Overall health uses live outstanding shopping count
- Adds a regression test preventing legacy values from returning

Install:
1. Extract this ZIP.
2. Copy TWO items into:
   C:\Projects\KitchenNavigator
   lib
   test
3. Choose Replace all.
4. Run:
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Test:
- Change the household monthly budget.
- Add/regenerate monthly meals.
- Open Shopping and mark products purchased.
- Return to Dashboard.
- Confirm Shopping count, weekly estimate and Budget update.

After successful testing:
   git add lib test
   git commit -m "Synchronize dashboard with Version 11 live data"
   git push
