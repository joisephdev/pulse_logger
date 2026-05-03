import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

void main() {
  group('LogLevel', () {
    test('exposes severity ordering from debug to critical', () {
      expect(LogLevel.debug.severity, 0);
      expect(LogLevel.info.severity, 1);
      expect(LogLevel.warning.severity, 2);
      expect(LogLevel.error.severity, 3);
      expect(LogLevel.critical.severity, 4);
    });

    test('supports comparison operators', () {
      expect(LogLevel.error >= LogLevel.warning, isTrue);
      expect(LogLevel.debug < LogLevel.info, isTrue);
      expect(LogLevel.critical > LogLevel.error, isTrue);
      expect(LogLevel.warning <= LogLevel.warning, isTrue);
    });
  });
}
