Kitchen Navigator V12 Beta 1.2 - Structured Starter Recipe Collection

Purpose:
Use the new Beta 1.1 Recipe Builder format in real built-in recipes without
expanding the release scope too aggressively.

What changed:
- 25 core built-in recipes now have structured quantity + unit ingredients.
- Existing recipe IDs, cooking instructions, categories, cuisines and timers
  remain intact.
- The rest of the existing 50-recipe library is NOT removed.
- This means Version 12 keeps the breadth users already had while the first
  25 recipes become much more useful for Pantry, Shopping and editing.

Structured examples:
- 500 g Chicken breast
- 300 ml Milk
- 2 tbsp Soy sauce
- 4 slice Bread
- 2 can Tuna
- 4 clove Garlic

The 25 upgraded recipes cover:
- Breakfast
- Chicken
- Beef
- Fish
- Pasta
with vegetarian/salad/dessert recipes still present in the existing library.

Version:
12.0.0-beta.1+51

Install AFTER the working Beta 1.1:
1. Stop Flutter.
2. Extract ZIP.
3. Copy lib, test and pubspec.yaml into C:\Projects\KitchenNavigator
4. Merge / Replace.
5. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Open several of the first 25 built-in recipes.
- Confirm ingredient quantities/units are readable.
- Add one to Shopping and check Pantry matching.
- Cook a timed recipe.
- Cook two upgraded recipes together.
- Confirm the rest of the recipe library still appears.

If successful, return to Beta QA. Do not add another major recipe/content
batch before RC1.
