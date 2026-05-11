import '../config/pulse_config.dart';
import '../pipeline/data_sanitizer.dart';
import '../platform/platform_context.dart';
import '../transport/multi_transport.dart';
import '../transport/transport.dart';
import 'log_event.dart';
import 'log_level.dart';

/// Callback invoked when event preparation or transport delivery fails.
///
/// Example:
/// ```dart
/// void report(Object error, StackTrace stackTrace) {}
/// ```
typedef PulseLoggerErrorCallback = void Function(
  Object error,
  StackTrace stackTrace,
);

/// Developer-facing facade for operational event logging.
///
/// Example:
/// ```dart
/// final logger = PulseLogger(config: config, transport: transport);
/// await logger.info(
///   event: 'user_login_started',
///   title: 'User login started',
///   message: 'The user selected Google as the provider.',
/// );
/// ```
class PulseLogger {
  /// Creates a logger using a single [transport].
  PulseLogger({
    required this.config,
    required this.transport,
    this.onError,
  }) : _sanitizer = DataSanitizer(
          additionalSensitiveKeys: config.sensitiveKeys,
          redactKeysBySubstring: config.redactKeysBySubstring,
        );

  /// Creates a logger that sends every event to multiple [transports].
  factory PulseLogger.multiChannel({
    required PulseConfig config,
    required List<Transport> transports,
    PulseLoggerErrorCallback? onError,
  }) {
    return PulseLogger(
      config: config,
      transport: PulseMultiTransport(transports),
      onError: onError,
    );
  }

  /// Runtime configuration for this logger.
  final PulseConfig config;

  /// Transport used to deliver events.
  final Transport transport;

  /// Optional callback invoked when event preparation or transport delivery
  /// fails.
  final PulseLoggerErrorCallback? onError;

  final DataSanitizer _sanitizer;

  /// Tracks a generic event with an explicit [level].
  Future<void> track({
    required String event,
    required String title,
    LogLevel level = LogLevel.info,
    String? message,
    Map<String, dynamic> properties = const <String, dynamic>{},
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (!config.enabled || level < config.minimumLevel) {
      return;
    }

    try {
      final logEvent = LogEvent(
        event: event,
        title: title,
        message: message,
        level: level,
        environment: config.environment,
        appName: config.appName,
        sessionId: config.sessionId,
        properties: await _sanitizedProperties(properties),
        error: error,
        stackTrace: stackTrace,
      );

      await transport.send(logEvent);
    } on Object catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      if (!config.silentFailures) {
        rethrow;
      }
    }
  }

  /// Tracks a debug event.
  Future<void> debug({
    required String event,
    required String title,
    String? message,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) {
    return track(
      event: event,
      title: title,
      message: message,
      level: LogLevel.debug,
      properties: properties,
    );
  }

  /// Tracks an info event.
  Future<void> info({
    required String event,
    required String title,
    String? message,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) {
    return track(
      event: event,
      title: title,
      message: message,
      level: LogLevel.info,
      properties: properties,
    );
  }

  /// Tracks a warning event.
  Future<void> warning({
    required String event,
    required String title,
    String? message,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) {
    return track(
      event: event,
      title: title,
      message: message,
      level: LogLevel.warning,
      properties: properties,
    );
  }

  /// Tracks an error event.
  Future<void> error({
    required String event,
    required String title,
    String? message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) {
    return track(
      event: event,
      title: title,
      message: message,
      level: LogLevel.error,
      properties: properties,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Tracks a critical event.
  Future<void> critical({
    required String event,
    required String title,
    String? message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) {
    return track(
      event: event,
      title: title,
      message: message,
      level: LogLevel.critical,
      properties: properties,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Releases resources held by the underlying transport.
  Future<void> dispose() => transport.dispose();

  Future<Map<String, dynamic>> _sanitizedProperties(
    Map<String, dynamic> properties,
  ) async {
    final merged = <String, dynamic>{
      ...config.defaultProperties,
      if (config.includePlatformContext) ...platformContext(),
      if (config.resolveProperties != null)
        ...await config.resolveProperties!(),
      ...properties,
    };

    if (config.appVersion != null) {
      merged['app_version'] = config.appVersion;
    }

    if (config.buildNumber != null) {
      merged['build_number'] = config.buildNumber;
    }

    return _sanitizer.sanitize(merged);
  }
}
