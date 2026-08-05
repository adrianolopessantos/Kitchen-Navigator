Kitchen Navigator v11.0 Beta 1 - Integration and Polish

Adds:
- Dashboard overview for today's plan
- Pantry waste-risk and restock summary
- Weekly shopping progress
- Family meal-rating summary
- Cooking feedback loaded into AppState
- Highly rated meals influence future planning
- Poorly rated, too-spicy and too-salty meals are deprioritized
- Pantry quantities automatically reduced after guided cooking
- Feedback refresh after cooking
- Planner and Cooking hub both update pantry and feedback
- End-to-end integration test for feedback-aware planning
- Version updated to 11.0.0-beta.1+31

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
- Open Dashboard and confirm Version 11 overview cards.
- Cook a planned recipe.
- Confirm pantry quantity decreases.
- Save a 5-star rating.
- Regenerate the meal plan and confirm family favourites are preferred.
- Confirm Shopping and Pantry still open normally.

After successful testing:
   git add .
   git commit -m "Add Version 11 Beta 1 integration and polish"
   git push
