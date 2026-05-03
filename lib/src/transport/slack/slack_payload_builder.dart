import 'dart:convert';

import '../../core/log_event.dart';
import '../../core/log_level.dart';

/// Builds Slack Incoming Webhook payloads from log events.
///
/// Example:
/// ```dart
/// final payload = SlackPayloadBuilder().build(event);
/// ```
class SlackPayloadBuilder {
  /// Creates a Slack payload builder.
  const SlackPayloadBuilder();

  /// Builds a Slack Incoming Webhook JSON payload for [event].
  Map<String, dynamic> build(LogEvent event) {
    final title = _plainText('${_emoji(event.level)} ${event.title}');
    final context = _mrkdwnText(_metadataLine(event));
    final fields = <Map<String, dynamic>>[
      _mrkdwnText('*Event*\n`${event.event}`'),
      _mrkdwnText('*Level*\n`${event.level.name}`'),
      _mrkdwnText('*Environment*\n`${event.environment}`'),
      _mrkdwnText('*App*\n`${event.appName}`'),
    ];

    if (event.sessionId != null) {
      fields.add(_mrkdwnText('*Session*\n`${event.sessionId}`'));
    }

    final blocks = <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'header',
        'text': title,
      },
      <String, dynamic>{
        'type': 'context',
        'elements': <Map<String, dynamic>>[context],
      },
      <String, dynamic>{
        'type': 'section',
        'fields': fields,
      },
    ];

    if (event.properties.isNotEmpty) {
      blocks.add(
        <String, dynamic>{
          'type': 'section',
          'text':
              _mrkdwnText('*Properties*\n```${_encode(event.properties)}```'),
        },
      );
    }

    if (event.error != null) {
      blocks.add(
        <String, dynamic>{
          'type': 'section',
          'text': _mrkdwnText('*Error*\n```${event.error}```'),
        },
      );
    }

    if (event.stackTrace != null) {
      blocks.add(
        <String, dynamic>{
          'type': 'section',
          'text': _mrkdwnText('*Stack trace*\n```${event.stackTrace}```'),
        },
      );
    }

    return <String, dynamic>{
      'text': '[${event.level.name.toUpperCase()}] ${event.title}',
      'attachments': <Map<String, dynamic>>[
        <String, dynamic>{
          'color': colorForLevel(event.level),
          'blocks': blocks,
        },
      ],
      'blocks': blocks,
    };
  }

  /// Returns the Slack attachment color used for [level].
  String colorForLevel(LogLevel level) {
    return switch (level) {
      LogLevel.debug => '#9CA3AF',
      LogLevel.info => '#2563EB',
      LogLevel.warning => '#F59E0B',
      LogLevel.error => '#DC2626',
      LogLevel.critical => '#7F1D1D',
    };
  }

  Map<String, dynamic> _plainText(String text) {
    return <String, dynamic>{
      'type': 'plain_text',
      'text': text,
      'emoji': true,
    };
  }

  Map<String, dynamic> _mrkdwnText(String text) {
    return <String, dynamic>{
      'type': 'mrkdwn',
      'text': text,
    };
  }

  String _metadataLine(LogEvent event) {
    return [
      event.timestamp.toIso8601String(),
      event.environment,
      event.appName,
    ].join(' | ');
  }

  String _emoji(LogLevel level) {
    return switch (level) {
      LogLevel.debug => ':mag:',
      LogLevel.info => ':information_source:',
      LogLevel.warning => ':warning:',
      LogLevel.error => ':x:',
      LogLevel.critical => ':rotating_light:',
    };
  }

  String _encode(Map<String, dynamic> value) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(value);
  }
}
