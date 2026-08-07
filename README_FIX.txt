Kitchen Navigator v12 Alpha 5 - Today Overflow Fix

Fix:
- Reapplies the proven Alpha 3 Today layout fix.
- Kitchen Overview cards receive slightly more vertical space.
- Quick Action vertical padding is slightly reduced.
- Resolves the small RenderFlex bottom overflow (~4.4 px).

Why it returned:
Alpha 5 was created from the earlier Alpha 3 Dashboard source,
before the dedicated overflow fix had been applied.

Install:
1. Extract this ZIP.
2. Copy the lib folder into:
   C:\Projects\KitchenNavigator
3. Choose Replace all / Merge folders.
4. Run:
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Check Today:
- Quick Actions
- Shopping / Pantry / Budget / Nutrition cards
- No yellow/black overflow warning

After successful testing:
   git add lib
   git commit -m "Reapply Today overflow fix to Alpha 5"
   git push
