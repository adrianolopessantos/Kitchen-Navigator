Kitchen Navigator v11 RC2 - Final Dashboard Test Fix

Fix:
- Removes the obsolete openNotificationCenter expectation
- Keeps checks for Kitchen overview, Scan, Budget, Shopping, Pantry and Nutrition
- Confirms the removed Kitchen Brief does not return

Install:
1. Extract this ZIP.
2. Copy the test folder into:
   C:\Projects\KitchenNavigator
3. Choose Replace all.
4. Run:
   C:\src\flutter\bin\flutter.bat test --reporter expanded

After all tests pass:
   git add test
   git commit -m "Fix final RC2 dashboard test expectation"
   git push
