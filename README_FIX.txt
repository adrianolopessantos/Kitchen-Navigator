Kitchen Navigator v11.0 RC1 - Shopping Price Visibility

Adds:
- Estimated total on every shopping row
- Still-to-buy estimated cost in the header
- Full-list estimated cost in the header
- Purchased products remain included in the full-list total
- Quantity changes update row and summary totals immediately
- Product Details shows quantity × unit price = item total
- Regression test for price visibility

Install:
1. Extract this ZIP.
2. Copy TWO items into:
   C:\Projects\KitchenNavigator
   lib
   test
3. Choose Replace all.
4. Run:
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Change a product quantity using + or -.
- Confirm its row total changes.
- Confirm Still to buy and Full list update.
- Mark a product purchased.
- Confirm Still to buy decreases while Full list remains unchanged.
- Open Product Details and confirm the calculation is shown.

After successful testing:
   git add lib test
   git commit -m "Show shopping item and list totals"
   git push
