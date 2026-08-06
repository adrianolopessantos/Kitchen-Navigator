Kitchen Navigator v11.0 RC2 - Workflow Repair

Fixes:
- Open Kitchen Brief now opens a live Today screen
- Today cards link to Planner, Shopping, Pantry, Nutrition and Notifications
- Purchased shopping products are added or merged into Pantry
- Existing Pantry products increase quantity instead of duplicating
- Recipe screen adds category filters
- Recipe screen adds 30-minute filter
- Recipe screen adds Recommended, Fastest and Name sorting
- Weekly Shopping Period cards open the correct Shopping week
- Weekly cards show meal count, shopping count and estimated cost
- Shopping screen adds Week and Month views
- Month view combines Pantry, Frozen, Household and Other products
- Fresh food remains in weekly shopping lists
- Version 11.0.0-rc.2+35

Install:
1. Confirm branch version-11-rc1.
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
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Open Today > Open kitchen brief and test every card.
- Mark a Shopping item purchased and confirm Pantry quantity increases.
- Mark the same product purchased again after adding it manually and confirm Pantry merges it.
- Filter Recipes by category and 30 minutes.
- Open Planner and tap a Weekly Shopping Period.
- Switch Shopping between Week and Month.
- Confirm fresh products stay weekly and pantry/frozen/household products appear monthly.

After successful testing:
   git add .
   git commit -m "Add Version 11 RC2 workflow repair"
   git push
