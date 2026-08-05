Kitchen Navigator v11.0 Alpha 6 - Open Planned Meal Fix

Fixes:
- Planner meal cards are now tappable
- Recipe meals open guided cooking
- Planned household servings are passed to cooking mode
- Completing a recipe opens Kitchen Memory feedback
- Simple foods display a meal summary
- Three-dot menu includes Cook, Regenerate, Lock and Remove

Install:
1. Extract this ZIP.
2. Copy the lib folder into:
   C:\Projects\KitchenNavigator
3. Choose Replace all.
4. Run:
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Test:
1. Open Planner.
2. Tap a recipe meal.
3. Complete guided cooking.
4. Save meal feedback.

After testing:
   git add lib
   git commit -m "Connect planned meals to cooking assistant"
   git push
