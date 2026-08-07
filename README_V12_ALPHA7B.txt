Kitchen Navigator v12 Alpha 7B - Cook Together + Pantry Health Contrast

Cook Together:
- Select 2 to 4 recipes from Recipes using the + circle on recipe cards.
- A Cook Together button appears once 2+ meals are selected.
- Up to four meal cards run in one cooking session.
- Each meal tracks its own step and timer.
- Moving to a timed next step starts that meal's timer automatically.
- Timers can be independently paused/resumed.
- Focus Now identifies the meal/action needing attention.
- Each meal can finish independently.
- Works with built-in and custom recipes.

Pantry Health:
- Replaces low-contrast dark-blue accents on the dark-green health card.
- Progress ring and PANTRY HEALTH label use light sage.
- Main copy uses warm off-white.
- Secondary copy uses light muted sage-gray.

Version: 12.0.0-alpha.7+45

Install:
1. Stop Flutter.
2. Extract ZIP.
3. Copy lib, test and pubspec.yaml into C:\Projects\KitchenNavigator
4. Merge / Replace.
5. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Pantry > check Pantry Health readability.
- Recipes > select 2 meals with + circles.
- Open Cook Together.
- Advance one meal into a timed step and confirm auto timer.
- Start/pause a second meal timer independently.
- Try 4 meals.
- Confirm a 5th selection is rejected.
- Finish meals independently.
- Confirm normal single-recipe Cook still works.

After successful testing:
   git add .
   git commit -m "Add Version 12 Alpha 7B Cook Together and Pantry Health contrast"
   git push
