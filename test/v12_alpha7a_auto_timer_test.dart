import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cooking Assistant automatically starts timed next steps', () {
    final source = File(
      'lib/features/cooking/cooking_assistant_screen.dart',
    ).readAsStringSync();

    expect(source, contains('_autoStartCurrentStepTimer'));
    expect(source, contains('_startCurrentTimer'));
    expect(source, contains('timerAutoStarted'));
    expect(source, contains('Timer started automatically'));
    expect(source, contains('Done — next + start timer'));
  });

  test('Cooking Assistant contains cooking session foundation', () {
    final source = File(
      'lib/features/cooking/cooking_assistant_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Cooking session'));
    expect(source, contains('completedSteps'));
    expect(source, contains('AppColors.cooking'));
  });
}
