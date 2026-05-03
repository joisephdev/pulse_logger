import '../core/log_event.dart';

/// Event delivery boundary implemented by concrete transports.
///
/// Example:
/// ```dart
/// final transport = MyTransport();
/// await transport.send(event);
/// ```
abstract class Transport {
  /// Sends [event] to the destination represented by this transport.
  ///
  /// Implementations own their I/O details and should honor the package's
  /// silent-failure policy when wired through the public facade.
  Future<void> send(LogEvent event);

  /// Releases resources held by this transport.
  Future<void> dispose() async {}
}
