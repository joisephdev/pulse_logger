import '../core/log_event.dart';
import 'transport.dart';

/// Transport that fans out each event to multiple transports.
///
/// Example:
/// ```dart
/// final transport = PulseMultiTransport([console, slack]);
/// await transport.send(event);
/// ```
class PulseMultiTransport implements Transport {
  /// Creates a fan-out transport.
  PulseMultiTransport(Iterable<Transport> transports)
      : transports = List<Transport>.unmodifiable(transports);

  /// Wrapped transports that receive every event.
  final List<Transport> transports;

  @override
  Future<void> send(LogEvent event) async {
    await Future.wait(
      transports.map((transport) => transport.send(event)),
    );
  }

  @override
  Future<void> dispose() async {
    await Future.wait(
      transports.map((transport) => transport.dispose()),
    );
  }
}
