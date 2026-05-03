import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

void main() {
  group('LogEvent', () {
    test('constructs with required fields and UTC timestamp', () {
      final event = LogEvent(
        event: 'user_login_started',
        title: 'User login started',
        level: LogLevel.info,
        environment: 'QA',
        appName: 'My App',
      );

      expect(event.event, 'user_login_started');
      expect(event.title, 'User login started');
      expect(event.level, LogLevel.info);
      expect(event.environment, 'QA');
      expect(event.appName, 'My App');
      expect(event.timestamp.isUtc, isTrue);
      expect(event.properties, isEmpty);
    });

    test('copies properties into an unmodifiable map', () {
      final properties = <String, dynamic>{'user_id': '123'};
      final event = LogEvent(
        event: 'payment_failed',
        title: 'Payment failed',
        level: LogLevel.error,
        environment: 'QA',
        appName: 'My App',
        properties: properties,
      );

      properties['user_id'] = '456';

      expect(event.properties['user_id'], '123');
      expect(
        () => event.properties['source'] = 'google',
        throwsUnsupportedError,
      );
    });

    test('keeps optional error, stack trace, and session id', () {
      final error = StateError('boom');
      final stackTrace = StackTrace.current;
      final timestamp = DateTime(2026, 5, 1);
      final event = LogEvent(
        event: 'payment_failed',
        title: 'Payment failed',
        level: LogLevel.error,
        timestamp: timestamp,
        error: error,
        stackTrace: stackTrace,
        environment: 'QA',
        appName: 'My App',
        sessionId: 'session-1',
      );

      expect(event.error, same(error));
      expect(event.stackTrace, same(stackTrace));
      expect(event.sessionId, 'session-1');
      expect(event.timestamp.isUtc, isTrue);
    });
  });
}
