Kitchen Navigator v10.1 - 50 Essential Recipes

Adds:
- 50 curated recipes with unique IDs R0001-R0050
- Breakfast, chicken, beef, fish, pasta, vegetarian, salad,
  dessert and quick-meal categories
- Description, category, cuisine and difficulty metadata
- Preparation, cooking and total time
- Servings
- Equipment requirements
- Oven and air-fryer temperatures where relevant
- Dietary and usage tags
- Ingredient lists and step-by-step instructions
- Recipe-browser badges
- Automated test confirming exactly 50 unique recipes

Install source update:
1. Stop Flutter with Ctrl+C.
2. Extract this ZIP.
3. Copy THREE items into C:\Projects\KitchenNavigator:
   - lib
   - test
   - pubspec.yaml
4. Choose Replace all.
5. Run:
   C:\src\flutter\bin\flutter.bat clean
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Create an installable APK after testing:
   C:\src\flutter\bin\flutter.bat build apk --release

APK output:
   C:\Projects\KitchenNavigator\build\app\outputs\flutter-apk\app-release.apk

You can copy app-release.apk to an Android phone and install it.
Android may ask you to allow installation from the app used to open the APK.
