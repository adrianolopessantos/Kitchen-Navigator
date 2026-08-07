Kitchen Navigator V12 Beta 1.3 — Final QA Freeze

This package adds NO product features.

It:
- Promotes the build to 12.0.0-beta.1+52
- Adds final regression guards
- Adds final release-cleanliness checks
- Adds a focused device QA checklist
- Freezes V12 features and recipe content before RC1

Install on top of the working Beta 1.2 project.

Copy:
  test
  pubspec.yaml
  V12_BETA13_FINAL_QA_CHECKLIST.txt

into:
  C:\Projects\KitchenNavigator

Then run:
  C:\src\flutter\bin\flutter.bat pub get
  C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
  C:\src\flutter\bin\flutter.bat test
  C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

If the checklist passes with no release-blocking issue, the next build is:
  Kitchen Navigator V12 Release Candidate 1
