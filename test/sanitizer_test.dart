import 'package:pulse_logger/src/pipeline/data_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('DataSanitizer', () {
    test('redacts built-in sensitive keys', () {
      final sanitizer = DataSanitizer();
      final sanitized = sanitizer.sanitize(<String, dynamic>{
        'token': 'abc',
        'access_token': 'def',
        'refresh_token': 'ghi',
        'authorization': 'Bearer abc',
        'password': 'secret',
        'secret': 'value',
        'webhook': 'https://hooks.slack.com/services/test',
        'credential': 'cred',
        'card_number': '4111111111111111',
        'cvv': 123,
        'api_key': 'key',
        'private_key': 'private',
      });

      expect(
        sanitized.values,
        everyElement(DataSanitizer.redactedValue),
      );
    });

    test('merges custom sensitive keys with defaults', () {
      final sanitizer = DataSanitizer(additionalSensitiveKeys: <String>[
        'email',
      ]);
      final sanitized = sanitizer.sanitize(<String, dynamic>{
        'token': 'abc',
        'email': 'person@example.com',
        'safe': 'visible',
      });

      expect(sanitized['token'], DataSanitizer.redactedValue);
      expect(sanitized['email'], DataSanitizer.redactedValue);
      expect(sanitized['safe'], 'visible');
    });

    test('matches sensitive keys case-insensitively', () {
      final sanitizer = DataSanitizer(additionalSensitiveKeys: <String>[
        'email',
      ]);
      final sanitized = sanitizer.sanitize(<String, dynamic>{
        'Authorization': 'Bearer abc',
        'EMAIL': 'person@example.com',
      });

      expect(sanitized['Authorization'], DataSanitizer.redactedValue);
      expect(sanitized['EMAIL'], DataSanitizer.redactedValue);
    });

    test('redacts keys containing sensitive fragments by default', () {
      final sanitizer = DataSanitizer(additionalSensitiveKeys: <String>[
        'email',
      ]);
      final sanitized = sanitizer.sanitize(<String, dynamic>{
        'firebase_id_token': 'abc',
        'user_email_address': 'person@example.com',
        'safe': 'visible',
      });

      expect(sanitized['firebase_id_token'], DataSanitizer.redactedValue);
      expect(sanitized['user_email_address'], DataSanitizer.redactedValue);
      expect(sanitized['safe'], 'visible');
    });

    test('can disable substring key matching', () {
      final sanitizer = DataSanitizer(
        additionalSensitiveKeys: <String>['email'],
        redactKeysBySubstring: false,
      );
      final sanitized = sanitizer.sanitize(<String, dynamic>{
        'firebase_id_token': 'abc',
        'user_email_address': 'person@example.com',
        'token': 'def',
      });

      expect(sanitized['firebase_id_token'], 'abc');
      expect(sanitized['user_email_address'], 'person@example.com');
      expect(sanitized['token'], DataSanitizer.redactedValue);
    });

    test('sanitizes nested maps and lists of maps', () {
      final sanitizer = DataSanitizer();
      final sanitized = sanitizer.sanitize(<String, dynamic>{
        'response': <String, dynamic>{
          'token': 'abc',
          'items': <Map<String, dynamic>>[
            <String, dynamic>{'password': 'secret', 'id': 1},
          ],
        },
      });

      final response = sanitized['response'] as Map<String, dynamic>;
      final items = response['items'] as List<dynamic>;
      final item = items.first as Map<String, dynamic>;

      expect(response['token'], DataSanitizer.redactedValue);
      expect(item['password'], DataSanitizer.redactedValue);
      expect(item['id'], 1);
    });

    test('keeps non-sensitive non-string values', () {
      final sanitizer = DataSanitizer();
      final sanitized = sanitizer.sanitize(<String, dynamic>{
        'amount': 49.99,
        'attempt': 2,
        'success': false,
      });

      expect(sanitized['amount'], 49.99);
      expect(sanitized['attempt'], 2);
      expect(sanitized['success'], isFalse);
    });

    test('does not mutate input maps', () {
      final sanitizer = DataSanitizer();
      final input = <String, dynamic>{
        'token': 'abc',
        'nested': <String, dynamic>{'password': 'secret'},
      };

      final sanitized = sanitizer.sanitize(input);

      expect(input['token'], 'abc');
      expect((input['nested'] as Map<String, dynamic>)['password'], 'secret');
      expect(sanitized['token'], DataSanitizer.redactedValue);
    });
  });
}
