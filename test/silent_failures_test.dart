import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

void main() {
  group('PulseLogger silent failures', () {
    test('swallows transport failures and invokes onError by default',
        () async {
      Object? capturedError;
      StackTrace? capturedStackTrace;
      final logger = PulseLogger(
        config: PulseConfig(environment: 'QA', appName: 'My App'),
        transport: _FailingTransport(),
        onError: (error, stackTrace) {
          capturedError = error;
          capturedStackTrace = stackTrace;
        },
      );

      await logger.info(event: 'will_fail', title: 'Will fail');

      expect(capturedError, isA<StateError>());
      expect(capturedStackTrace, isNotNull);
    });

    test('rethrows transport failures when silentFailures is false', () async {
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
          silentFailures: false,
        ),
        transport: _FailingTransport(),
      );

      await expectLater(
        logger.info(event: 'will_fail', title: 'Will fail'),
        throwsA(isA<StateError>()),
      );
    });
  });
}

class _FailingTransport implements Transport {
  @override
  Future<void> send(LogEvent event) async {
    throw StateError('transport failed');
  }

  @override
  Future<void> dispose() async {}
}
