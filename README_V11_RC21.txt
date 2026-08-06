Kitchen Navigator v11.0 RC2.1 - Today and Recipe Polish

Dashboard:
- Removes the duplicate Open Kitchen Brief entry
- Keeps only Today, Quick Actions and Kitchen Overview
- Replaces AI Kitchen quick action with Scan
- Scan is context-aware:
  - Shopping match: mark purchased and add to Pantry
  - Pantry match: increase Pantry quantity
  - Unknown item: add to Pantry or Shopping

Recipe Details:
- Add missing and Cook are now in a sticky bottom action bar
- Bottom action bar respects Android SafeArea
- Recipe content scrolls independently above the buttons
- Add missing now correctly adds products to Shopping
- Buttons are no longer covered by phone navigation

Install:
1. Extract this ZIP.
2. Copy THREE items into C:\Projects\KitchenNavigator:
   lib
   test
   pubspec.yaml
3. Choose Replace all.
4. Run:
   C:\src\flutter\bin\flutter.bat clean
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Confirm Today shows only Today, Quick Actions and Kitchen Overview.
- Tap Scan and test the available actions.
- Open a recipe with many ingredients and steps.
- Scroll to the bottom.
- Confirm Add missing and Cook remain visible above the phone navigation bar.
- Tap Add missing and confirm products appear in Shopping.

After successful testing:
   git add .
   git commit -m "Simplify Today and fix recipe bottom actions"
   git push
