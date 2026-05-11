import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

void main() {
  group('ConsoleTransport', () {
    test('formats a readable one-line summary and indented properties', () {
      final event = LogEvent(
        event: 'user_login_started',
        title: 'User login started',
        message: 'The user selected Google as the auth provider.',
        level: LogLevel.info,
        timestamp: DateTime.utc(2026, 5, 1, 12, 30),
        environment: 'QA',
        appName: 'My App',
        sessionId: 'session-1',
        properties: <String, dynamic>{
          'user_id': '123',
          'source': 'google',
        },
      );

      final output = const ConsoleTransport(useColor: false).format(event);

      expect(output, contains('2026-05-01T12:30:00.000Z'));
      expect(output, contains('INFO user_login_started - User login started'));
      expect(output, contains('[QA / My App]'));
      expect(output, contains('session=session-1'));
      expect(output, contains('message: The user selected Google'));
      expect(output, contains('  "user_id": "123"'));
      expect(output, contains('  "source": "google"'));
    });

    test('adds ANSI color codes when enabled', () {
      final event = LogEvent(
        event: 'payment_failed',
        title: 'Payment failed',
        level: LogLevel.error,
        timestamp: DateTime.utc(2026, 5, 1),
        environment: 'production',
        appName: 'My App',
      );

      final output = const ConsoleTransport().format(event);

      expect(output, contains('\u001B[31mERROR\u001B[0m'));
    });

    test('implements Transport', () {
      const transport = ConsoleTransport();

      expect(transport, isA<Transport>());
    });
  });
}
