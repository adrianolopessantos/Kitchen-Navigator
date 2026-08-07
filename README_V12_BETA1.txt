Kitchen Navigator V12 Beta 1 - Stability & Release Hardening

This is intentionally NOT a feature release.

It:
- Promotes the build to 12.0.0-beta.1+49.
- Preserves the latest Pantry Health contrast correction.
- Adds regression guards for Cook Together, audio, known overflow fixes,
  Insights nutrition fields, feature colors and core V12 screens.
- Adds a full Android device QA checklist.
- Starts the Version 12 feature freeze.

Install on top of the currently working Alpha 9 build.

Copy:
  lib
  test
  pubspec.yaml
  V12_BETA1_DEVICE_QA_CHECKLIST.txt

into C:\Projects\KitchenNavigator

Then run:
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings
C:\src\flutter\bin\flutter.bat test
C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Do not move to RC1 until the phone checklist is completed without a blocking
runtime, persistence or overflow problem.
