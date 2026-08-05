Kitchen Navigator v11.0 Alpha 3 - Shopping Intelligence

Adds:
- Weekly shopping trips generated from the monthly meal plan
- Week 1–5 selector
- Pantry-aware ingredient filtering
- Recipe ingredient aggregation
- Simple-food shopping entries
- Shopping list grouping by supermarket aisle
- Weekly and monthly estimated costs
- Weekly budget comparison from the household profile
- Purchased-item progress
- Reset checks for one week
- Swipe-right purchased toggle
- Barcode scanner restored and integrated
- Scanned products added to Pantry
- Matching shopping items automatically checked
- Automated shopping-period and barcode-flow tests

Install:
1. Confirm the active branch is version-11.
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

Test:
- Generate a monthly meal plan.
- Open Shopping.
- Switch between Weeks 1–5.
- Check that products are grouped by aisle.
- Confirm pantry products are omitted.
- Mark products purchased.
- Tap Scan and test a barcode.
- Confirm weekly budget indicators.

After successful testing:
   git add .
   git commit -m "Add Version 11 shopping intelligence"
   git push
