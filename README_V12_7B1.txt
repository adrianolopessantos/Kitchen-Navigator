Kitchen Navigator v12 - Alpha 7B.1 Usability Repair

Fix 1 - Receipts right overflow:
- Receipt Scanner title is now responsive.
- Camera / Gallery actions switch from a horizontal Row to stacked full-width
  buttons on narrow Android screens.
- Prevents the ~90 px right-side overflow.

Fix 2 - Cook Together discoverability:
- Recipes now has an always-visible:
    Cook Together · 2–4 meals
  button.
- Tap it to enter selection mode.
- Instructions appear:
    Tap 2 to 4 recipe cards to select your meals.
- Tap recipe cards to select/deselect.
- Selected meals show a clear check circle.
- Once 2+ meals are selected, press Start.
- Maximum remains 4 meals.
- After the cooking session, selection mode closes automatically.

Also restores the responsive Alpha 6 Recipes header and wrapping filter layout
that Alpha 7B accidentally regressed.

Install:
1. Stop Flutter.
2. Extract ZIP.
3. Copy lib and test into:
   C:\Projects\KitchenNavigator
4. Merge / Replace.
5. Run:
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
A) Receipt Scanner:
   - Open Receipts / Receipt Scanner.
   - Confirm no yellow/black right overflow.
   - Confirm Take photo and Gallery are usable.

B) Cook Together:
   - Open Recipes.
   - Tap "Cook Together · 2–4 meals".
   - Tap 2 recipe cards.
   - Press Start.
   - Confirm both meals appear in the combined cooking session.
   - Repeat with 4 meals.
   - Confirm a 5th meal cannot be selected.

After successful testing:
   git add lib test
   git commit -m "Fix Cook Together discovery and receipt overflow"
   git push
