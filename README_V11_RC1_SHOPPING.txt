Kitchen Navigator v11.0 RC1 - Shopping Editor

Adds:
- Clean shopping rows focused on product, quantity, unit and purchased state
- Large plus/minus quantity controls
- Unit-aware steps: 0.1 kg/L, 50 g/ml, 1 for countable products
- Tap quantity or unit to edit exact values
- Add custom grocery and household products
- Edit product name, quantity, unit, aisle, week and estimated price
- Swipe left to delete
- Undo after deletion
- Purchased checkbox
- Purchased products moved to a separate section at the bottom
- Aisle/category grouping
- Recipe sources hidden from the main list
- Recipe sources available in Product Details
- Manual item badge
- User overrides persist after app restart and plan regeneration
- Barcode scanner retained
- Automated state and UI regression tests
- Version 11.0.0-rc.1+34

Install:
1. Confirm branch:
   git branch
   It should show version-11-rc1.

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
- Add a manual product.
- Use plus and minus.
- Tap the quantity and enter an exact value.
- Change the unit and aisle.
- Mark the item purchased and confirm it moves to Purchased.
- Swipe an item left and test Undo.
- Regenerate the meal plan and confirm shopping edits remain.
- Open Product Details and confirm recipe sources appear only there.

After successful testing:
   git add .
   git commit -m "Add RC1 editable shopping experience"
   git push
