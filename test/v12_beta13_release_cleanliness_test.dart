import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('No obvious temporary release markers remain in lib', () {
    final root = Directory('lib');
    final suspicious = <String>[];

    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final source = entity.readAsStringSync();
      for (final marker in const [
        'TODO TEMP',
        'REMOVE BEFORE RELEASE',
        'DEBUG ONLY',
        'HACK FOR TEST',
      ]) {
        if (source.contains(marker)) {
          suspicious.add('${entity.path}: $marker');
        }
      }
    }

    expect(
      suspicious,
      isEmpty,
      reason: 'Release blockers found: $suspicious',
    );
  });
}
