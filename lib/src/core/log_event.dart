import 'log_level.dart';

/// Immutable operational event routed through Pulse Logger transports.
///
/// Example:
/// ```dart
/// final event = LogEvent(
///   event: 'payment_failed',
///   title: 'Payment failed',
///   level: LogLevel.error,
///   environment: 'QA',
///   appName: 'Checkout',
/// );
/// ```
class LogEvent {
  /// Creates an immutable event with a UTC timestamp.
  factory LogEvent({
    required String event,
    required String title,
    required LogLevel level,
    required String environment,
    required String appName,
    DateTime? timestamp,
    Map<String, dynamic> properties = const <String, dynamic>{},
    Object? error,
    StackTrace? stackTrace,
    String? sessionId,
  }) {
    return LogEvent._(
      event: event,
      title: title,
      level: level,
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: Map<String, dynamic>.unmodifiable(properties),
      error: error,
      stackTrace: stackTrace,
      environment: environment,
      appName: appName,
      sessionId: sessionId,
    );
  }

  const LogEvent._({
    required this.event,
    required this.title,
    required this.level,
    required this.timestamp,
    required this.properties,
    required this.environment,
    required this.appName,
    this.error,
    this.stackTrace,
    this.sessionId,
  });

  /// Stable machine-readable event name, such as `user_login_started`.
  final String event;

  /// Human-readable event title for transport formatters.
  final String title;

  /// Severity level for routing and filtering.
  final LogLevel level;

  /// UTC timestamp captured when the event was created.
  final DateTime timestamp;

  /// Structured event metadata.
  final Map<String, dynamic> properties;

  /// Optional error object associated with the event.
  final Object? error;

  /// Optional stack trace associated with [error].
  final StackTrace? stackTrace;

  /// Environment label, such as `QA`, `staging`, or `production`.
  final String environment;

  /// Application name displayed by transports.
  final String appName;

  /// Optional session identifier used to correlate related events.
  final String? sessionId;
}
