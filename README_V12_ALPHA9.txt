Kitchen Navigator v12.0 Alpha 9 - Whole-App Visual Polish

Goal:
Make Version 12 feel like one coherent product before Beta/RC.
This update is presentation-only and intentionally avoids changing kitchen logic.

Global:
- Slightly softer cards and shadows
- More compact bottom navigation
- Consistent icon sizing
- Consistent ListTile spacing
- Branded tooltip styling
- Shared FeatureHeader and FeatureSectionLabel visual primitives

Feature identity:
- Shopping: orange
- Pantry: sage
- Recipes: bamboo
- Planner: indigo
- Cooking: copper
- Insights: blue
- Today: forest green

Screen polish:
- Shopping header identity
- Pantry accent bar
- Recipes accent bar
- Planner identity
- Cooking app-bar identity
- Receipt accent treatment
- Insights accent treatment
- Today Insights card gets subtle info tint

Version:
12.0.0-alpha.9+48

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

Phone regression test:
- Today / Insights
- Shopping brand + quantity controls
- Pantry scanner and Pantry Health
- Recipes custom recipe + Cook Together
- Planner monthly workflow
- Cooking single recipe + multi-meal audio
- Receipt scanner
- Watch for any horizontal/bottom overflow

After successful testing:
   git add .
   git commit -m "Complete Version 12 Alpha 9 visual polish"
   git push

Next:
V12 Beta 1 - stability, persistence, full-device QA and release hardening.
