import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Today keeps Kitchen Navigator identity', () {
    final source = File('lib/features/dashboard/dashboard_screen.dart').readAsStringSync();
    expect(source, contains("'Kitchen Navigator'"));
    expect(source, contains('greeting'));
  });

  test('Pantry has direct scanner action', () {
    final source = File('lib/features/pantry/pantry_screen.dart').readAsStringSync();
    expect(source, contains('Scan into Pantry'));
    expect(source, contains('_scanIntoPantry'));
    expect(source, contains('openBarcodeScanner'));
  });

  test('Recipes can be manually created and persisted', () {
    final screen = File('lib/features/recipes/recipes_screen.dart').readAsStringSync();
    final state = File('lib/core/state/app_state.dart').readAsStringSync();
    expect(screen, contains("'Add recipe'"));
    expect(screen, contains("'Save recipe'"));
    expect(state, contains('addCustomRecipe'));
    expect(state, contains('_customRecipesStorageKey'));
  });

  test('Android adaptive icon resources are present', () {
    expect(File('android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml').existsSync(), isTrue);
    expect(File('android/app/src/main/res/drawable/ic_launcher_foreground.png').existsSync(), isTrue);
  });
}
