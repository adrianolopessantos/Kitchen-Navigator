Kitchen Navigator v11.0 RC2 - Automated Test Refresh

Updates obsolete tests that still expected removed Version 10/Beta UI.

Replaced expectations:
- Removed "Everything at a glance"
- Removed "Open Kitchen Brief"
- Removed old "Smart shopping" heading
- Removed old Pantry health card assumptions
- Removed old Beta 2 dashboard section names

Current test baseline verifies:
- Application starts successfully
- Today is visible
- Dashboard contains Today, Quick actions and Kitchen overview
- Dashboard Scan action exists
- Compact Pantry rows and details exist
- Shopping editor, Week/Month views and price totals exist
- Planner opens the selected shopping week
- Recipe filters and sticky Add missing/Cook controls exist
- Version 11 RC2 core workflow source is present

Install:
1. Extract this ZIP.
2. Copy the test folder into:
   C:\Projects\KitchenNavigator
3. Choose Replace all.
4. Run:
   C:\src\flutter\bin\flutter.bat test --reporter expanded

If another test fails, send the FIRST full exception section.

After all tests pass:
   git add test
   git commit -m "Refresh Version 11 RC2 automated tests"
   git push
