Kitchen Navigator v9.9.5 Final Shopping Compile Fix

Fixes:
- Removes the last toggleShoppingItem() call
- Uses toggleShoppingChecked(item.key) everywhere
- Resolves the compile error at shopping_screen.dart line 296

Install:
1. Extract this ZIP.
2. Copy the lib folder into:
   C:\Projects\KitchenNavigator
3. Choose Replace all.
4. Run:
   C:\src\flutter\bin\flutter.bat clean
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat test
5. Then launch:
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA
