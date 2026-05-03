import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

import 'mock_transport.dart';

void main() {
  group('PulseMultiTransport', () {
    test('sends the same event to every transport', () async {
      final first = MockTransport();
      final second = MockTransport();
      final event = _event();
      final transport = PulseMultiTransport(<Transport>[first, second]);

      await transport.send(event);

      expect(first.events, <LogEvent>[event]);
      expect(second.events, <LogEvent>[event]);
    });

    test('disposes every transport', () async {
      final first = MockTransport();
      final second = MockTransport();
      final transport = PulseMultiTransport(<Transport>[first, second]);

      await transport.dispose();

      expect(first.disposed, isTrue);
      expect(second.disposed, isTrue);
    });

    test('copies transports into an immutable list', () {
      final source = <Transport>[MockTransport()];
      final transport = PulseMultiTransport(source);

      source.add(MockTransport());

      expect(transport.transports, hasLength(1));
      expect(() => transport.transports.add(MockTransport()),
          throwsUnsupportedError);
    });
  });
}

LogEvent _event() {
  return LogEvent(
    event: 'user_login_started',
    title: 'User login started',
    level: LogLevel.info,
    environment: 'QA',
    appName: 'My App',
  );
}
