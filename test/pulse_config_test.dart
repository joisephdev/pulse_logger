import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

void main() {
  group('PulseConfig', () {
    test('uses production-safe defaults', () {
      final config = PulseConfig(
        environment: 'QA',
        appName: 'My App',
      );

      expect(config.enabled, isTrue);
      expect(config.silentFailures, isTrue);
      expect(config.includePlatformContext, isTrue);
      expect(config.redactKeysBySubstring, isTrue);
      expect(config.timeout, const Duration(seconds: 5));
      expect(config.minimumLevel, LogLevel.debug);
      expect(config.defaultProperties, isEmpty);
      expect(config.sensitiveKeys, isEmpty);
      expect(config.resolveProperties, isNull);
    });

    test('copies default properties and custom sensitive keys', () {
      final defaultProperties = <String, dynamic>{'team': 'mobile'};
      final sensitiveKeys = <String>['email'];
      final config = PulseConfig(
        environment: 'production',
        appName: 'My App',
        defaultProperties: defaultProperties,
        sensitiveKeys: sensitiveKeys,
      );

      defaultProperties['team'] = 'backend';
      sensitiveKeys.add('phone');

      expect(config.defaultProperties['team'], 'mobile');
      expect(config.sensitiveKeys, <String>['email']);
      expect(
        () => config.defaultProperties['x'] = 'y',
        throwsUnsupportedError,
      );
      expect(() => config.sensitiveKeys.add('phone'), throwsUnsupportedError);
    });

    test('keeps optional app and session metadata', () {
      final config = PulseConfig(
        environment: 'QA',
        appName: 'My App',
        sessionId: 'session-1',
        appVersion: '1.2.3',
        buildNumber: '42',
      );

      expect(config.sessionId, 'session-1');
      expect(config.appVersion, '1.2.3');
      expect(config.buildNumber, '42');
    });

    test('keeps optional dynamic property resolver', () async {
      final config = PulseConfig(
        environment: 'QA',
        appName: 'My App',
        resolveProperties: () => <String, dynamic>{'user_id': '123'},
      );

      expect(await config.resolveProperties!(), <String, dynamic>{
        'user_id': '123',
      });
    });
  });
}
