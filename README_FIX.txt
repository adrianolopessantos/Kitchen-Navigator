Kitchen Navigator v11.0 Alpha 5 - Planner String Fix

Fixes:
- Repairs malformed Dart string interpolation in the meal-card subtitle
- Suggestion reasons now appear on a second line
- Resolves planner_screen.dart errors around lines 553-557

Install:
1. Extract this ZIP.
2. Copy the lib folder into:
   C:\Projects\KitchenNavigator
3. Choose Replace all.
4. Run:
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

After successful testing:
   git add lib
   git commit -m "Fix Alpha 5 planner suggestion text"
   git push
