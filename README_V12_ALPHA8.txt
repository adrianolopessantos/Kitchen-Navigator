Kitchen Navigator v12.0 Alpha 8 - Insights & Analytics

Adds a practical Insights Center accessible from Today.

Insights includes:
- Weekly shopping estimate vs weekly budget
- Remaining / over-budget status
- Pantry health
- Use-soon / low-stock / waste-risk counts
- Estimated pantry waste value
- Shopping completion progress
- Today nutrition summary
- Weekly estimated calories
- Needs Attention section with actionable summaries

Design:
- Uses the official Version 12 feature colors
- No external chart dependency
- Compact cards and progress bars instead of decorative charts
- Responsive layout for phone widths

Version:
12.0.0-alpha.8+46

Install:
1. Stop Flutter.
2. Extract ZIP.
3. Copy:
   lib
   test
   pubspec.yaml
   into C:\Projects\KitchenNavigator
4. Merge / Replace.
5. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Today > Insights.
- Confirm Budget values match Today/Shopping.
- Confirm Pantry health/waste data match Pantry.
- Confirm Shopping remaining count matches the list.
- Confirm Nutrition values match Nutrition.
- Check the page for any overflow on your Android phone.

After successful testing:
   git add .
   git commit -m "Add Version 12 Alpha 8 Insights and Analytics"
   git push
