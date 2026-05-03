import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

void main() {
  group('SlackPayloadBuilder', () {
    const builder = SlackPayloadBuilder();

    test('builds text, attachments, and blocks', () {
      final event = _event();

      final payload = builder.build(event);

      expect(payload['text'], '[INFO] User login started');
      expect(payload['attachments'], isA<List<dynamic>>());
      expect(payload['blocks'], isA<List<dynamic>>());
      expect(payload['attachments'], isNotEmpty);
      expect(payload['blocks'], isNotEmpty);
    });

    test('maps colors for every level', () {
      expect(builder.colorForLevel(LogLevel.debug), '#9CA3AF');
      expect(builder.colorForLevel(LogLevel.info), '#2563EB');
      expect(builder.colorForLevel(LogLevel.warning), '#F59E0B');
      expect(builder.colorForLevel(LogLevel.error), '#DC2626');
      expect(builder.colorForLevel(LogLevel.critical), '#7F1D1D');
    });

    test('renders core metadata and properties', () {
      final payload = builder.build(
        _event(
          properties: <String, dynamic>{
            'user_id': '123',
            'source': 'google',
          },
        ),
      );
      final serialized = payload.toString();

      expect(serialized, contains('User login started'));
      expect(serialized, contains('user_login_started'));
      expect(serialized, contains('2026-05-01T12:30:00.000Z'));
      expect(serialized, contains('QA'));
      expect(serialized, contains('My App'));
      expect(serialized, contains('session-1'));
      expect(serialized, contains('user_id'));
      expect(serialized, contains('google'));
    });

    test('renders error and stack trace blocks', () {
      final error = StateError('boom');
      final stackTrace = StackTrace.fromString('frame 1');
      final payload = builder.build(
        _event(error: error, stackTrace: stackTrace),
      );
      final serialized = payload.toString();

      expect(serialized, contains('Bad state: boom'));
      expect(serialized, contains('frame 1'));
      expect(serialized, contains('Stack trace'));
    });
  });
}

LogEvent _event({
  Map<String, dynamic> properties = const <String, dynamic>{},
  Object? error,
  StackTrace? stackTrace,
}) {
  return LogEvent(
    event: 'user_login_started',
    title: 'User login started',
    level: LogLevel.info,
    timestamp: DateTime.utc(2026, 5, 1, 12, 30),
    environment: 'QA',
    appName: 'My App',
    sessionId: 'session-1',
    properties: properties,
    error: error,
    stackTrace: stackTrace,
  );
}
