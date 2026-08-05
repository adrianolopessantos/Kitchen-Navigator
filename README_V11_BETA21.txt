Kitchen Navigator v11.0 Beta 2.1 - Nutrition Clarity

Fixes and additions:
- Dashboard no longer shows misleading 0 kcal values
- Days without analyzable meals show Nutrition analysis pending
- Dashboard nutrition values are labeled as household estimates
- Detailed Nutrition Intelligence screen
- Whole-household calories, protein, carbohydrates and fat
- Individual estimates for each family member
- Age-based serving allocation for adults and children
- Serving-share percentage shown for each person
- All estimates are clearly labeled
- Medical-advice disclaimer
- Automated family-allocation and Dashboard regression tests
- Version 11.0.0-beta.2.1+33

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

Phone test:
- Select a day with no meals and confirm Nutrition analysis pending.
- Plan meals for today.
- Return to Dashboard and confirm the household estimate appears.
- Tap Nutrition.
- Confirm every family member receives an individual estimate.
- Confirm the member totals approximately equal the household total.

After successful testing:
   git add .
   git commit -m "Add nutrition clarity and family estimates"
   git push
