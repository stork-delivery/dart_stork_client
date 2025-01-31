import 'package:dart_stork_client/src/extensions/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DateExtension', () {
    group('serialize', () {
      test('converts DateTime to UTC ISO string', () {
        final date = DateTime(2025, 1, 31, 19, 46, 45);
        expect(date.serialize(), equals('2025-01-31T22:46:45.000Z'));
      });
    });

    group('deserialize', () {
      test('parses valid ISO string to local DateTime', () {
        const dateString = '2025-01-31T22:46:45.000Z';
        final result = DateExtension.deserialize(dateString);
        expect(result.year, equals(2025));
        expect(result.month, equals(1));
        expect(result.day, equals(31));
      });

      test('returns epoch date when parsing invalid string', () {
        final result = DateExtension.deserialize('invalid-date');
        expect(
          result,
          equals(DateTime.fromMillisecondsSinceEpoch(0)),
          reason:
              'Should return epoch date (1970-01-01) for invalid date string',
        );
      });
    });
  });
}
