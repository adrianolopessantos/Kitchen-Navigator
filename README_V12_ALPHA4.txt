Kitchen Navigator v12.0 Alpha 4 - Shopping & Pantry Visual Refresh

This is a visual-first update. It does not intentionally change inventory,
shopping calculations, pantry synchronization, or planner logic.

Shopping:
- Orange Version 12 identity
- Product stays visually primary
- Grocery brand remains visible and secondary
- Existing quantity +/- controls, units, prices, purchased state and swipe
  behavior are preserved
- Existing safe Product Details footer is preserved

Pantry:
- Sage Version 12 identity
- Compact rows are preserved
- Swipe delete and Undo are preserved
- Details remain out of the main list to avoid clutter

Pantry source lineage used: Kitchen_Navigator_v11.0_RC2.2_Compact_Pantry.zip

Version: 12.0.0-alpha.4+41

Install:
1. Confirm: git branch -> version-12
2. Stop Flutter.
3. Extract this ZIP.
4. Copy lib, test and pubspec.yaml into C:\Projects\KitchenNavigator
5. Merge / Replace.
6. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone checks:
- Shopping still shows Brand for each product.
- +/- quantity and prices still work.
- Product Details Save changes does not cover lower content.
- Pantry remains compact.
- Pantry swipe delete + Undo still work.
- No overflow warnings.

After successful testing:
   git add .
   git commit -m "Add Version 12 Shopping and Pantry visual refresh"
   git push
