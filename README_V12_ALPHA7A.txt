Kitchen Navigator v12.0 Alpha 7A - Cooking Assistant 2.0 Foundation

Adds:
- Done / Next Step automatically starts the timer when the NEXT step has a duration.
- Voice "next" uses the same nextStep flow, so timed steps also auto-start.
- Untimed steps continue normally.
- Returning to Previous does NOT automatically restart timers.
- Timer can still be paused, reset or extended manually.
- Auto-started timers show a small "Timer started automatically" indicator.
- Done button tells you when the next action will also start a timer.
- Adds a Cooking Session progress strip as foundation for Alpha 7B multi-meal orchestration.
- Version 12.0.0-alpha.7+44

Important:
This is Alpha 7A: one-recipe cooking remains the active workflow.
Alpha 7B will add Cook Together for 1-4 simultaneous meals with independent timers.

Install:
1. Stop Flutter.
2. Extract ZIP.
3. Copy lib, test and pubspec.yaml into:
   C:\Projects\KitchenNavigator
4. Merge / Replace.
5. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
1. Open a recipe with a timed SECOND step.
2. Start cooking.
3. Finish step 1.
4. Tap "Done — next + start timer".
5. Confirm step 2 opens and its timer immediately begins counting down.
6. Pause / resume / reset.
7. Go Previous and confirm no unwanted timer starts.
8. Try voice "next" if voice cooking is enabled.

After successful testing:
   git add .
   git commit -m "Add Version 12 Alpha 7A automatic cooking timers"
   git push
