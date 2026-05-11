import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

import 'mock_transport.dart';

void main() {
  group('PulseLogger', () {
    test('track builds and sends a sanitized event', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
          sessionId: 'session-1',
          appVersion: '1.2.3',
          buildNumber: '42',
          defaultProperties: const <String, dynamic>{
            'team': 'mobile',
            'token': 'default-secret',
          },
          sensitiveKeys: const <String>['email'],
        ),
        transport: transport,
      );

      await logger.track(
        event: 'user_login_started',
        title: 'User login started',
        properties: const <String, dynamic>{
          'source': 'google',
          'email': 'person@example.com',
        },
      );

      expect(transport.events, hasLength(1));
      final event = transport.events.single;
      expect(event.event, 'user_login_started');
      expect(event.title, 'User login started');
      expect(event.level, LogLevel.info);
      expect(event.environment, 'QA');
      expect(event.appName, 'My App');
      expect(event.sessionId, 'session-1');
      expect(event.timestamp.isUtc, isTrue);
      expect(event.properties['team'], 'mobile');
      expect(event.properties['source'], 'google');
      expect(event.properties['token'], '[REDACTED]');
      expect(event.properties['email'], '[REDACTED]');
      expect(event.properties['app_version'], '1.2.3');
      expect(event.properties['build_number'], '42');
      expect(event.properties, contains('platform'));
    });

    test('per-event properties override default properties', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
          defaultProperties: const <String, dynamic>{'team': 'mobile'},
        ),
        transport: transport,
      );

      await logger.info(
        event: 'override_test',
        title: 'Override test',
        properties: const <String, dynamic>{'team': 'backend'},
      );

      expect(transport.events.single.properties['team'], 'backend');
    });

    test('per-event properties override platform context properties', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
        ),
        transport: transport,
      );

      await logger.info(
        event: 'platform_override',
        title: 'Platform override',
        properties: const <String, dynamic>{'platform': 'custom'},
      );

      expect(transport.events.single.properties['platform'], 'custom');
    });

    test('does not add platform context when disabled', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
          includePlatformContext: false,
        ),
        transport: transport,
      );

      await logger.info(event: 'no_platform', title: 'No platform');

      expect(transport.events.single.properties, isNot(contains('platform')));
    });

    test('merges dynamic properties before per-event properties', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
          includePlatformContext: false,
          resolveProperties: () => <String, dynamic>{
            'is_logged_in': true,
            'user_id': '123',
            'source': 'dynamic',
          },
        ),
        transport: transport,
      );

      await logger.info(
        event: 'dynamic_context',
        title: 'Dynamic context',
        properties: const <String, dynamic>{'source': 'event'},
      );

      expect(transport.events.single.properties['is_logged_in'], isTrue);
      expect(transport.events.single.properties['user_id'], '123');
      expect(transport.events.single.properties['source'], 'event');
    });

    test('reports dynamic property resolver failures', () async {
      final transport = MockTransport();
      Object? reportedError;
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
          resolveProperties: () => throw StateError('missing profile'),
        ),
        transport: transport,
        onError: (error, stackTrace) {
          reportedError = error;
        },
      );

      await logger.info(event: 'resolver_failed', title: 'Resolver failed');

      expect(transport.events, isEmpty);
      expect(reportedError, isA<StateError>());
    });

    test('rethrows dynamic property resolver failures when configured',
        () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
          silentFailures: false,
          resolveProperties: () => throw StateError('missing profile'),
        ),
        transport: transport,
      );

      expect(
        logger.info(event: 'resolver_failed', title: 'Resolver failed'),
        throwsStateError,
      );
      expect(transport.events, isEmpty);
    });

    test('passes message through level helpers', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(environment: 'QA', appName: 'My App'),
        transport: transport,
      );

      await logger.warning(
        event: 'retry_scheduled',
        title: 'Retry scheduled',
        message: 'The job will retry in 30 seconds.',
      );

      expect(
        transport.events.single.message,
        'The job will retry in 30 seconds.',
      );
    });

    test('does not send when disabled', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
          enabled: false,
        ),
        transport: transport,
      );

      await logger.info(event: 'ignored', title: 'Ignored');

      expect(transport.events, isEmpty);
    });

    test('filters events below minimum level', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(
          environment: 'QA',
          appName: 'My App',
          minimumLevel: LogLevel.warning,
        ),
        transport: transport,
      );

      await logger.info(event: 'ignored', title: 'Ignored');
      await logger.warning(event: 'sent', title: 'Sent');

      expect(transport.events, hasLength(1));
      expect(transport.events.single.level, LogLevel.warning);
    });

    test('level helpers emit their expected levels', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(environment: 'QA', appName: 'My App'),
        transport: transport,
      );

      await logger.debug(event: 'debug', title: 'Debug');
      await logger.info(event: 'info', title: 'Info');
      await logger.warning(event: 'warning', title: 'Warning');
      await logger.error(event: 'error', title: 'Error');
      await logger.critical(event: 'critical', title: 'Critical');

      expect(
        transport.events.map((event) => event.level),
        <LogLevel>[
          LogLevel.debug,
          LogLevel.info,
          LogLevel.warning,
          LogLevel.error,
          LogLevel.critical,
        ],
      );
    });

    test('multiChannel wraps transports in PulseMultiTransport', () async {
      final first = MockTransport();
      final second = MockTransport();
      final logger = PulseLogger.multiChannel(
        config: PulseConfig(environment: 'QA', appName: 'My App'),
        transports: <Transport>[first, second],
      );

      await logger.info(event: 'fan_out', title: 'Fan out');

      expect(logger.transport, isA<PulseMultiTransport>());
      expect(first.events, hasLength(1));
      expect(second.events, hasLength(1));
    });

    test('dispose delegates to transport', () async {
      final transport = MockTransport();
      final logger = PulseLogger(
        config: PulseConfig(environment: 'QA', appName: 'My App'),
        transport: transport,
      );

      await logger.dispose();

      expect(transport.disposed, isTrue);
    });
  });
}
