import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Version 12 brand foundation is installed', () {
    final theme = File(
      'lib/core/theme/app_theme.dart',
    ).readAsStringSync();
    final app = File('lib/app.dart').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(theme, contains('Color(0xFF1F5D3B)'));
    expect(theme, contains('Color(0xFFC99A4B)'));
    expect(theme, contains('GoogleFonts.poppins'));
    expect(theme, contains('static ThemeData light()'));
    expect(theme, contains('static const budget'));
    expect(theme, contains('static const shopping'));
    expect(theme, contains('static const pantry'));

    expect(app, contains('AppTheme.light()'));
    expect(app, contains('kitchen_navigator_icon.png'));
    expect(app, contains('Your guide from pantry to plate.'));

    // V12 release stages move through alpha, beta and RC builds.
    // Guard the major version without pinning an obsolete Alpha 1 build.
    expect(pubspec, contains(RegExp(r'version:\s*12\.0\.0-')));
    expect(pubspec, contains('google_fonts:'));
  });

  test('Official launcher icon files are present', () {
    expect(
      File('assets/images/kitchen_navigator_icon.png').existsSync(),
      isTrue,
    );
    expect(
      File(
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
      ).existsSync(),
      isTrue,
    );
  });
}
