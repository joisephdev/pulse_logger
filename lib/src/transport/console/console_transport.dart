import 'dart:convert';
import 'dart:developer' as developer;

import '../../core/log_event.dart';
import '../../core/log_level.dart';
import '../transport.dart';

/// Local development transport that writes events with `dart:developer.log`.
///
/// Example:
/// ```dart
/// final transport = ConsoleTransport();
/// await transport.send(event);
/// ```
class ConsoleTransport implements Transport {
  /// Creates a console transport.
  const ConsoleTransport({this.useColor = true});

  /// Whether ANSI color codes should be applied to the level label.
  final bool useColor;

  /// Formats [event] into the string emitted by [send].
  String format(LogEvent event) {
    final buffer = StringBuffer()
      ..write(event.timestamp.toIso8601String())
      ..write(' ')
      ..write(_formatLevel(event.level))
      ..write(' ')
      ..write(event.event)
      ..write(' - ')
      ..write(event.title)
      ..write(' [')
      ..write(event.environment)
      ..write(' / ')
      ..write(event.appName)
      ..write(']');

    if (event.sessionId != null) {
      buffer
        ..write(' session=')
        ..write(event.sessionId);
    }

    if (event.properties.isNotEmpty) {
      buffer
        ..writeln()
        ..write(_formatProperties(event.properties));
    }

    if (event.error != null) {
      buffer
        ..writeln()
        ..write('  error: ')
        ..write(event.error);
    }

    if (event.stackTrace != null) {
      buffer
        ..writeln()
        ..write('  stackTrace: ')
        ..write(event.stackTrace);
    }

    return buffer.toString();
  }

  @override
  Future<void> send(LogEvent event) async {
    developer.log(
      format(event),
      name: 'pulse_logger',
      level: event.level.severity,
      error: event.error,
      stackTrace: event.stackTrace,
    );
  }

  @override
  Future<void> dispose() async {}

  String _formatLevel(LogLevel level) {
    final label = level.name.toUpperCase();
    if (!useColor) {
      return label;
    }

    return '${_ansiColor(level)}$label\u001B[0m';
  }

  String _ansiColor(LogLevel level) {
    return switch (level) {
      LogLevel.debug => '\u001B[90m',
      LogLevel.info => '\u001B[34m',
      LogLevel.warning => '\u001B[33m',
      LogLevel.error => '\u001B[31m',
      LogLevel.critical => '\u001B[35m',
    };
  }

  String _formatProperties(Map<String, dynamic> properties) {
    const encoder = JsonEncoder.withIndent('  ');
    final encoded = encoder.convert(properties).split('\n');
    return encoded.map((line) => '  $line').join('\n');
  }
}
