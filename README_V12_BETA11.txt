Kitchen Navigator V12 Beta 1.1 - Recipe Builder & Contrast Fix

Recipe Builder:
- Ingredients are now structured instead of typed as free-form lines.
- Each ingredient has:
  Product name
  Quantity
  Unit selector
  Delete control
- Common units include:
  g, kg, ml, L, tsp, tbsp, cup, each, piece, clove, slice, can, pack
- Add Ingredient creates another row.

Cooking steps:
- Each step has a dedicated instruction field.
- Timer is optional.
- Timer units:
  No timer, seconds, minutes, hours
- Add Step creates another cooking step.
- Clean timer data feeds directly into single-meal and Cook Together auto-timers.
- Existing custom recipes are converted into editable structured rows when opened.

Contrast:
- Pantry top + Add Product button now uses white + on forest green.
- Compact Recipes + button also uses explicit white foreground.

Version:
12.0.0-beta.1+50

Install on top of the working V12 Beta 1 / Alpha 9 app:
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
- Pantry: confirm top + is clearly white and visible.
- Recipes > Add: build a recipe using ingredient quantity/unit rows.
- Add and remove ingredient rows.
- Build steps using No timer / seconds / minutes / hours.
- Save recipe.
- Reopen recipe and confirm structured information remains editable.
- Cook the recipe and confirm timed steps start correctly.
- Try it inside Cook Together.
- Watch for horizontal/bottom overflow with keyboard open.

After successful testing:
   git add .
   git commit -m "Add V12 Beta 1.1 structured recipe builder and contrast fix"
   git push
