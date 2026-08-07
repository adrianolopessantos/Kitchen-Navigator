Kitchen Navigator v12.0 Alpha 8 - Consolidated Insights Build

This package deliberately consolidates the latest working Version 12 fixes
before continuing development.

Preserved from Alpha 7B / 7B.1 / 7B.2:
- Cook Together for 2-4 meals
- Clear Cook Together selection mode
- Responsive Recipes header and filters
- Independent multi-meal timers
- Automatic next-step timers
- Timer Alerts
- Voice Guidance
- Repeat Focus
- Meal-specific spoken timer alerts
- Responsive Receipt Scanner header/actions
- Pantry Health high-contrast sage/cream colors

Alpha 8 adds:
- Today > Insights
- Weekly budget vs shopping estimate
- Pantry health, waste risk and estimated waste value
- Shopping completion
- Today nutrition and weekly calorie summary
- Needs Attention section
- Correct NutritionTotals.carbohydrates field

Version:
12.0.0-alpha.8+47

Install:
1. Stop Flutter.
2. Extract ZIP.
3. Copy:
   lib
   test
   pubspec.yaml
   into C:\Projects\KitchenNavigator
4. Merge / Replace.
5. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Regression test on phone:
1. Today:
   - Kitchen Navigator identity remains visible.
   - No 4.4 px bottom overflow.
   - Open Insights.

2. Insights:
   - Budget / Pantry / Shopping / Nutrition render.
   - No compile or horizontal overflow.
   - Compare values with source pages.

3. Recipes:
   - Cook Together button visible.
   - Select 2-4 meals.
   - Multi-meal cooking starts.

4. Cooking:
   - Voice Guidance works.
   - Timer Alerts identify meal name.
   - Auto-start timer still works.

5. Receipts:
   - No right-side 90 px overflow.

6. Pantry:
   - Pantry Health remains readable on dark green.

After successful testing:
   git add .
   git commit -m "Complete Version 12 Alpha 8 consolidated insights build"
   git push

Next:
Alpha 9 - Whole-app visual polish and consistency.
