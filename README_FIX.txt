Kitchen Navigator v11.0 RC2.2 - Compact Pantry

Changes:
- Replaces large multi-button Pantry cards with compact rows
- Shows only product, quantity, unit, location and expiry/status
- Tap a row to open Product Details
- Details contain Use some, Edit, Add to Shopping and Record as waste
- Swipe left to delete
- Undo after deletion
- Search retained
- Location filters retained
- Adds sorting by Needs attention, Expiry, Name and Location
- Reduces vertical space so large inventories are easier to scan
- Adds SafeArea and keyboard-close protection to Pantry editor
- Adds UI and state regression tests

Install:
1. Extract this ZIP.
2. Copy TWO items into:
   C:\Projects\KitchenNavigator
   lib
   test
3. Choose Replace all.
4. Run:
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Open Pantry with many products.
- Confirm many more rows fit on screen.
- Tap a product and test Use some, Edit and Add to Shopping.
- Swipe a product left and test Undo.
- Test Search, location filters and all sort options.

After successful testing:
   git add lib test
   git commit -m "Add compact RC2 pantry experience"
   git push
