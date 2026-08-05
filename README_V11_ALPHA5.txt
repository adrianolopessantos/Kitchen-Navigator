Kitchen Navigator v11.0 Alpha 5 - Personalized Meal Generator

Adds:
- Personalized full-month local meal generation
- Family size and ages used for servings
- Allergy avoidance
- Dietary preference filtering
- Likes and dislikes
- Preferred cuisine scoring
- Weekday cooking-time limits
- Pantry-first recipe scoring
- Strong priority for products expiring soon
- Equipment compatibility
- Budget-friendly ingredient-list scoring
- Planned leftovers
- Simple fruit, yogurt, toast and snack options
- Variety controls to reduce repeated recipes
- Explanation shown for each generated meal
- Regenerate one meal
- Regenerate one day
- Regenerate one week
- Regenerate the whole month
- Locked meals always preserved
- AI-ready request/result architecture
- No user AI account required for the local generator
- Automated allergy, locking and explanation tests

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
- Add allergies, dislikes and preferred cuisines to the family profile.
- Add pantry products and expiry dates.
- Add available kitchen equipment.
- Open Planner and create a personalized month.
- Read the reason shown under generated meals.
- Lock one meal and regenerate the month.
- Confirm the locked meal remains.
- Regenerate one meal, one day and one week.

After successful testing:
   git add .
   git commit -m "Add Version 11 personalized meal generator"
   git push
