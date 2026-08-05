Kitchen Navigator v11.0 Alpha 6 - Cooking Assistant 2.0

Adds:
- Cooking hub connected to today's monthly plan
- Start guided cooking directly from planned recipes
- Existing step-by-step voice cooking assistant retained
- Household serving quantities passed into cooking mode
- Numeric ingredient scaling service
- Post-cooking family feedback
- 1–5 star rating
- Everyone-liked-it response
- Too spicy and too salty flags
- Portion-size feedback
- Free-form Kitchen Memory notes
- Local feedback persistence
- Recipe-specific feedback history service
- Cooking timer data foundation for future multi-timer UI
- Automated scaling and feedback persistence tests

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
- Plan a recipe for today.
- Open Cooking.
- Start the planned recipe.
- Test next, previous, repeat and timer voice controls.
- Complete the cooking session.
- Save a rating and Kitchen Memory note.
- Restart and confirm normal app operation.

After successful testing:
   git add .
   git commit -m "Add Version 11 cooking assistant 2.0"
   git push
