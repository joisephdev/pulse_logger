import 'package:pulse_logger/pulse_logger.dart';

/// Test transport that captures sent events in memory.
class MockTransport implements Transport {
  /// Events captured through [send].
  final List<LogEvent> events = <LogEvent>[];

  /// Whether [dispose] has been called.
  bool disposed = false;

  @override
  Future<void> send(LogEvent event) async {
    events.add(event);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}
