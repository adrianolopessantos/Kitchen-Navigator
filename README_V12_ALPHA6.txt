Kitchen Navigator v12.0 Alpha 6 - Recipes & Planner 2.0

Recipes:
- Bamboo Version 12 identity
- My recipes filter
- Custom recipe badge
- Edit / Duplicate / Delete
- Reusable Add/Edit recipe editor
- Timed custom steps can use: Simmer sauce | 10 min
- Custom changes persist locally

Planner:
- Preserves the full Version 11 RC2 monthly Planner and weekly-shopping workflow
- Planner already uses state.recipes, so custom recipes participate in the same recipe collection
- Existing shopping-week connections remain intact

Version: 12.0.0-alpha.6+43

Install:
1. Stop Flutter.
2. Extract ZIP.
3. Copy lib, test and pubspec.yaml into C:\Projects\KitchenNavigator
4. Merge / Replace.
5. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Add custom recipe
- Search/filter My recipes
- Edit it
- Duplicate it
- Delete the copy
- Restart app and confirm persistence
- Open Planner and verify normal monthly planning and weekly shopping still work

After successful testing:
   git add .
   git commit -m "Add Version 12 Alpha 6 Recipes and Planner 2.0"
   git push
