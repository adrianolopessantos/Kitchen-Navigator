import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Main lib source contains no obvious temporary debug markers', () {
    final root = Directory('lib');
    expect(root.existsSync(), isTrue);

    final dartFiles = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    final suspicious = <String>[];
    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      if (source.contains('TODO TEMP') ||
          source.contains('REMOVE BEFORE RELEASE') ||
          source.contains('DEBUG ONLY')) {
        suspicious.add(file.path);
      }
    }

    expect(
      suspicious,
      isEmpty,
      reason: 'Temporary release markers found: $suspicious',
    );
  });
}
