Kitchen Navigator v12.0 Alpha 2 - Home Logo + Shopping Brands

Adds:
- Replaces the remaining old Today/Home logo with the official
  compass cutting-board Kitchen Navigator icon
- Adds optional Brand to the ShoppingItem product model
- Brand persists in saved manual items and shopping overrides
- Add/Edit Product includes Brand (optional)
- Shopping search finds products by product name or brand
- Shopping rows show brand as compact secondary text
- Barcode scanning automatically carries the detected brand into Shopping
- Existing products without a brand continue to work unchanged
- Version updated to 12.0.0-alpha.2+39

Example:
  Barilla
  Spaghetti No. 5              €3.00
  [ - ] 2 [ + ] packs

Install:
1. Confirm:
   git branch
   * version-12

2. Stop Flutter with Ctrl+C.

3. Extract this ZIP.

4. Copy THREE items into C:\Projects\KitchenNavigator:
   lib
   test
   pubspec.yaml

5. Choose Replace all / Merge folders.

6. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Open Today and confirm the official cutting-board compass logo appears.
- Open Shopping > Add product.
- Enter a Brand and Product.
- Save and confirm brand appears above the product name.
- Search using the brand name.
- Edit the item and confirm brand is retained.
- Scan a branded barcode and confirm its detected brand is carried into
  the shopping item when possible.

After successful testing:
   git add .
   git commit -m "Add Version 12 home logo and shopping brands"
   git push
