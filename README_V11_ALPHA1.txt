Kitchen Navigator v11.0 Alpha 1 - Family Foundation

This is the first integrated Version 11 feature.

Adds:
- First-run household setup wizard
- Household name and monthly food budget
- Multiple adults and children
- Age for each family member
- Dietary preferences
- Allergies
- Likes and dislikes
- Meals and snacks per day
- Maximum weekday cooking time
- Preferred cuisines
- Pantry-first planning preference
- Leftover planning preference
- Local SharedPreferences persistence
- Household editing from Settings
- Household data in diagnostics
- Household profile reset support
- Automated model and persistence tests

Install on version-11 branch:
1. Confirm:
   git branch
   The active branch must be version-11.

2. Stop Flutter with Ctrl+C.

3. Extract this ZIP.

4. Copy THREE items into C:\Projects\KitchenNavigator:
   lib
   test
   pubspec.yaml

5. Choose Replace all.

6. Run:
   C:\src\flutter\bin\flutter.bat clean
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

7. After phone testing:
   git add .
   git commit -m "Add Version 11 family foundation"
   git push

First launch:
- Existing users will see the household wizard once.
- Complete the four steps and save.
- Existing pantry, recipes, equipment, budget, and meal-plan data remain unchanged.
- The household profile can later be edited in Settings > Household & family.

Suggested GitHub board action:
- Move "Version 11 Architecture" to Testing after tests pass.
- Move "Family Setup Wizard" to In Progress while testing the UI.
