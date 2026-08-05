Kitchen Navigator v11.0 Alpha 2 - Monthly Meal Planner Foundation

Adds:
- Full calendar month view
- Previous/next month navigation
- Household-driven meal and snack slots
- Simple food entries such as fruit, yogurt, toast and leftovers
- Recipe entries
- Household-size servings
- Lock/unlock individual meals
- Clear only unlocked meals from a day
- Starter month generation for 28, 29, 30 or 31 days
- Regeneration that preserves locked meals
- Weekly shopping-period summaries
- SharedPreferences persistence
- Automated model and persistence tests

Install on version-11:
1. Stop Flutter with Ctrl+C.
2. Extract this ZIP.
3. Copy THREE items into C:\Projects\KitchenNavigator:
   lib
   test
   pubspec.yaml
4. Choose Replace all.
5. Run:
   C:\src\flutter\bin\flutter.bat clean
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

After testing:
   git add .
   git commit -m "Add Version 11 monthly planner foundation"
   git push

Suggested board action:
- Move Monthly Meal Planner to Testing after phone verification.
- Keep AI Meal Generator in Backlog; Alpha 2 uses a deterministic local
  starter generator so the planner works without an AI account.
