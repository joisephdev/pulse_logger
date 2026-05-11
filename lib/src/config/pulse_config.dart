import 'dart:async';

import '../core/log_level.dart';

/// Resolves dynamic properties that are merged into each emitted event.
typedef PulsePropertiesResolver = FutureOr<Map<String, dynamic>> Function();

/// Immutable runtime configuration shared by Pulse Logger components.
///
/// Example:
/// ```dart
/// final config = PulseConfig(
///   environment: 'QA',
///   appName: 'Checkout',
/// );
/// ```
class PulseConfig {
  /// Creates configuration with production-safe defaults.
  PulseConfig({
    required this.environment,
    required this.appName,
    this.enabled = true,
    this.silentFailures = true,
    this.includePlatformContext = true,
    this.redactKeysBySubstring = true,
    this.timeout = const Duration(seconds: 5),
    this.minimumLevel = LogLevel.debug,
    Map<String, dynamic> defaultProperties = const <String, dynamic>{},
    Iterable<String> sensitiveKeys = const <String>[],
    this.resolveProperties,
    this.sessionId,
    this.appVersion,
    this.buildNumber,
  })  : defaultProperties =
            Map<String, dynamic>.unmodifiable(defaultProperties),
        sensitiveKeys = List<String>.unmodifiable(sensitiveKeys);

  /// Whether events should be processed.
  final bool enabled;

  /// Environment label, such as `QA`, `staging`, or `production`.
  final String environment;

  /// Application name attached to every event.
  final String appName;

  /// Minimum event level that should be emitted.
  final LogLevel minimumLevel;

  /// Properties merged into every event before transport delivery.
  final Map<String, dynamic> defaultProperties;

  /// Whether SDK failures should be swallowed by default.
  final bool silentFailures;

  /// Whether platform context should be collected when available.
  final bool includePlatformContext;

  /// Whether sensitive keys redact keys that contain known fragments.
  final bool redactKeysBySubstring;

  /// Timeout budget used by transports that perform I/O.
  final Duration timeout;

  /// Additional sensitive keys redacted by the logging pipeline.
  final List<String> sensitiveKeys;

  /// Optional callback used to resolve dynamic properties for each event.
  final PulsePropertiesResolver? resolveProperties;

  /// Optional session identifier attached to emitted events.
  final String? sessionId;

  /// Optional app version attached to emitted events.
  final String? appVersion;

  /// Optional build number attached to emitted events.
  final String? buildNumber;
}
