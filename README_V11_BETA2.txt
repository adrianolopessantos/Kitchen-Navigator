Kitchen Navigator v11.0 Beta 2 - Daily Intelligence

This consolidated update focuses on features that do not require new
Android permissions or native notification plugins.

Adds:
- In-app smart notification center
- Meal-plan reminder
- Shopping-list reminder
- Expiry-risk alert
- Budget forecast alert
- Monthly-planning reminder
- Read/unread notification state
- Notification settings for Shopping, Expiry and Budget
- Daily nutrition estimate
- Calories, protein, carbohydrates and fat
- Meal-variety score
- Monthly budget forecast
- Remaining budget and over-budget target
- Waste-risk and recorded-waste summary
- Dashboard 2.0 intelligence cards
- Notification badge on Dashboard
- Automated notification, nutrition, budget and dashboard tests
- Version 11.0.0-beta.2+32

Important:
These are in-app smart alerts. Android background/push notification
permissions are intentionally deferred to the Release Candidate to avoid
adding native build risk during Beta 2.

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
- Open Dashboard and inspect Daily intelligence.
- Open the bell icon and mark notifications read.
- Change notification settings.
- Change the household budget and regenerate the plan.
- Confirm the budget forecast updates.
- Add expiring pantry products and confirm an expiry alert appears.
- Confirm nutrition changes when today's meal plan changes.

After successful testing:
   git add .
   git commit -m "Add Version 11 Beta 2 daily intelligence"
   git push
