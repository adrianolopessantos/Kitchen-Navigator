Kitchen Navigator v12.0 Alpha 1 - Brand Foundation

This is the first Version 12 update. It intentionally leaves Version 11
business logic unchanged and applies the new visual foundation globally.

Adds:
- Official compass + cutting-board Kitchen Navigator app icon
- Android launcher icons
- Warm Cream light visual foundation
- Forest Green primary brand color
- Sage, Bamboo and Copper supporting colors
- Official feature accent colors for:
  Today, Planner, Shopping, Pantry, Recipes, Cooking, Nutrition,
  Budget, Household, Notifications and Settings
- Poppins typography through google_fonts
- Version 12 cards, buttons, chips, inputs, dialogs and bottom sheets
- Softer premium shadows and rounded corners
- Branded app-loading screen
- Version updated to 12.0.0-alpha.1+38
- Automated brand-foundation regression tests

Important:
This update changes the appearance globally but does not redesign individual
screens yet. Some older screen layouts may therefore look different while
retaining their Version 11 structure. The Today redesign is the next step.

Install:
1. Create/switch to your Version 12 branch before installing:
   git checkout -b version-12
   git push -u origin version-12

   If the branch already exists:
   git checkout version-12

2. Stop Flutter with Ctrl+C.

3. Extract this ZIP.

4. Copy FOUR items into C:\Projects\KitchenNavigator:
   lib
   test
   assets
   android
   pubspec.yaml

5. Choose Replace all / Merge folders.

6. Run:
   C:\src\flutter\bin\flutter.bat clean
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Look for:
- Cream background instead of the Version 11 dark background
- Forest-green primary controls
- New Poppins typography
- Softer white cards
- Rounded premium buttons and inputs
- New compass cutting-board launcher icon
- Branded loading screen

After successful testing:
   git add .
   git commit -m "Start Version 12 brand foundation"
   git push
