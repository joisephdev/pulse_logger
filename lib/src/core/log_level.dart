/// Severity levels supported by Pulse Logger.
///
/// Example:
/// ```dart
/// if (LogLevel.error >= LogLevel.warning) {
///   // Send the event.
/// }
/// ```
enum LogLevel {
  /// Verbose diagnostic events useful during development.
  debug(0),

  /// Normal operational events that confirm expected progress.
  info(1),

  /// Recoverable problems or unusual states that deserve attention.
  warning(2),

  /// Failed operations that should be investigated.
  error(3),

  /// High-impact failures that may require immediate action.
  critical(4);

  /// Creates a log level with its sortable severity.
  const LogLevel(this.severity);

  /// Numeric severity used to compare levels.
  final int severity;

  /// Returns `true` when this level is less severe than [other].
  bool operator <(LogLevel other) => severity < other.severity;

  /// Returns `true` when this level is less than or equal to [other].
  bool operator <=(LogLevel other) => severity <= other.severity;

  /// Returns `true` when this level is more severe than [other].
  bool operator >(LogLevel other) => severity > other.severity;

  /// Returns `true` when this level is greater than or equal to [other].
  bool operator >=(LogLevel other) => severity >= other.severity;
}
