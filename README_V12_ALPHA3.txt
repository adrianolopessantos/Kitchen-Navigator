Kitchen Navigator v12.0 Alpha 3 - Premium Today Dashboard

This update changes only the Today/Dashboard presentation.
Shopping, Pantry, Planner and household business logic remain untouched.

New Today experience:
- Official Kitchen Navigator compass cutting-board logo
- Time-aware Good morning / Good afternoon / Good evening greeting
- Current date and active kitchen
- Premium Forest Green Today focus card
- Cleaner meal priority with one clear call to action
- Four compact color-coded Quick Actions:
  Planner / Shopping / Pantry / Scan
- Four compact Kitchen Overview cards:
  Shopping / Pantry / Budget / Nutrition
- Official Version 12 section accent colors
- Low-stock and use-soon attention strip
- Cleaner spacing, typography and visual hierarchy
- Dashboard scanner now preserves detected grocery brands
- Version 12.0.0-alpha.3+40

Install:
1. Confirm the branch:
   git branch
   * version-12

2. Stop Flutter with Ctrl+C.

3. Extract this ZIP.

4. Copy THREE items into C:\Projects\KitchenNavigator:
   lib
   test
   pubspec.yaml

5. Choose Replace all / Merge folders.

6. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Open Today.
- Confirm the greeting changes with the time of day.
- Confirm the official logo is visible.
- Check the green Today focus card.
- Tap Plan, Shop, Pantry and Scan.
- Open Shopping, Pantry, Budget and Nutrition from Kitchen Overview.
- Check that cards fit cleanly without text overflow.

After successful testing:
   git add .
   git commit -m "Add Version 12 premium Today dashboard"
   git push
