Kitchen Navigator v11.0 Alpha 4 - Pantry Intelligence

Adds:
- Pantry usage history
- Record partial product consumption
- Record discarded/wasted products
- Predicted days remaining from recent usage
- Fallback stock prediction for new products
- Monthly-plan ingredient demand per pantry product
- Waste-risk detection for expiring products not used by the plan
- Smart restock quantity suggestions
- Potential waste-value estimate
- Pantry coverage count for planned meals
- Risk-first pantry sorting
- Restock and use-soon actions
- Persistence separated for each kitchen
- Automated prediction, waste-risk and serialization tests

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
- Add pantry products with quantities and expiry dates.
- Generate a monthly meal plan.
- Open Pantry Intelligence.
- Confirm planned-use counts.
- Record partial consumption.
- Restart and confirm the reduced quantity persists.
- Record a test product as waste.
- Confirm low-stock and use-soon suggestions appear.

After successful testing:
   git add .
   git commit -m "Add Version 11 pantry intelligence"
   git push
