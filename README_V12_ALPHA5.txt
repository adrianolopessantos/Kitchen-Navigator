Kitchen Navigator v12.0 Alpha 5 - Identity, Pantry Scan, Custom Recipes & Adaptive Icon

Adds:
- Today shows Kitchen Navigator above the time-aware greeting.
- Pantry gets a dedicated Scan action.
- Pantry scans default to Add to Pantry / increase matching stock.
- Recipes gets Add recipe for manual custom recipes.
- Custom recipes persist locally per kitchen and join normal search/filter/cooking.
- Android launcher becomes an adaptive icon with a full Forest Green background.
- Legacy Android launcher icons are also regenerated with full green coverage.
- Version 12.0.0-alpha.5+42

Custom recipe entry:
Recipe name, category, cuisine, servings, prep minutes, ingredients, steps, notes.
Use one ingredient and one step per line.

Install:
1. Stop Flutter.
2. Extract ZIP.
3. Copy lib, test, android, assets and pubspec.yaml into C:\Projects\KitchenNavigator.
4. Merge / Replace.
5. Run:
   C:\src\flutter\bin\flutter.bat clean
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Important launcher test:
Because Android launchers cache icons, if the old icon still appears:
   C:\src\flutter\bin\flutter.bat clean
Then uninstall Kitchen Navigator from the phone and run it again.

Phone test:
- Today: Kitchen Navigator + greeting are both visible.
- Pantry: tap Scan; scan a product; confirm Add to Pantry/increase quantity.
- Recipes: Add recipe; save; search it; open it.
- Restart app and confirm custom recipe remains.
- Launcher: full green background reaches the Android icon mask edges.

After successful testing:
   git add .
   git commit -m "Add Version 12 Alpha 5 identity pantry scan custom recipes and adaptive icon"
   git push
