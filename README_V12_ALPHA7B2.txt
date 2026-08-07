Kitchen Navigator v12 Alpha 7B.2 - Multi-Meal Audio & Alerts

Cook Together improvements:
- Timer alerts are ON by default.
- When a meal timer reaches zero, Kitchen Navigator speaks:
    "<meal name> timer finished."
- Meal completion can announce:
    "<meal name> is complete."
- Voice Guidance is ON by default.
- When Focus Now changes, Kitchen Navigator announces the meal and instruction.
- Repeat Focus lets you hear the current priority again.
- Timer Alerts and Voice Guidance can each be turned on/off independently.
- A finished timer also gets a visible "Timer finished · action needed" warning.
- Controls use Wrap so they remain safe on narrow Android screens.

Uses the existing VoiceCookingService / flutter_tts dependency; no new audio
package is required.

Version: 12.0.0-alpha.7+46

Important:
Install this AFTER the working Alpha 7B.1 repair. This package only replaces
the Cooking Assistant and pubspec/test additions, so it preserves the
Cook Together discovery and Receipt overflow fixes already installed.

Install:
1. Stop Flutter.
2. Extract ZIP.
3. Copy lib, test and pubspec.yaml into C:\Projects\KitchenNavigator
4. Merge / Replace.
5. Run:
   C:\src\flutter\bin\flutter.bat pub get
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Recipes > Cook Together > select 2 meals > Start.
- Confirm Voice Guidance announces Focus Now.
- Advance a meal to a timed step.
- Let the timer reach 00:00.
- Confirm you hear "<meal> timer finished."
- Confirm the meal card shows "Timer finished · action needed".
- Test Timer Alerts OFF.
- Test Voice Guidance OFF.
- Test Repeat Focus.
- Run two timers at once and confirm each meal is identified by name.

After successful testing:
   git add .
   git commit -m "Add Cook Together audio alerts and voice guidance"
   git push
