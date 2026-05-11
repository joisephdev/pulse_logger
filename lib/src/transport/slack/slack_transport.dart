import 'dart:async';
import 'dart:convert';

import '../../core/log_event.dart';
import '../transport.dart';
import 'slack_http_client.dart';
import 'slack_payload_builder.dart';

/// Exception thrown when Slack delivery fails.
///
/// Example:
/// ```dart
/// try {
///   await transport.send(event);
/// } on SlackTransportException {
///   // Handle or let the future PulseLogger facade swallow it.
/// }
/// ```
class SlackTransportException implements Exception {
  /// Creates a Slack transport exception.
  const SlackTransportException(this.message, {this.cause});

  /// Human-readable failure description.
  final String message;

  /// Optional underlying error.
  final Object? cause;

  @override
  String toString() {
    if (cause == null) {
      return 'SlackTransportException: $message';
    }
    return 'SlackTransportException: $message ($cause)';
  }
}

/// Sends events to Slack through an Incoming Webhook.
///
/// Example:
/// ```dart
/// final transport = SlackTransport(webhookUrl: webhookUrl);
/// await transport.send(event);
/// ```
class SlackTransport implements Transport {
  /// Creates a Slack transport with optional injectable dependencies.
  SlackTransport({
    required String webhookUrl,
    this.timeout = const Duration(seconds: 5),
    Future<({int statusCode, String body})> Function(
      Uri url,
      Map<String, String> headers,
      String body,
    )? post,
    SlackPayloadBuilder? payloadBuilder,
  })  : webhookUrl = Uri.parse(webhookUrl),
        _httpClient = post == null ? SlackHttpClient() : null,
        _postOverride = post,
        _payloadBuilder = payloadBuilder ?? const SlackPayloadBuilder();

  /// Slack Incoming Webhook URL owned by this transport.
  final Uri webhookUrl;

  /// Timeout budget for webhook POST requests.
  final Duration timeout;

  final SlackHttpClient? _httpClient;
  final Future<({int statusCode, String body})> Function(
    Uri url,
    Map<String, String> headers,
    String body,
  )? _postOverride;
  final SlackPayloadBuilder _payloadBuilder;

  @override
  Future<void> send(LogEvent event) async {
    final payload = _payloadBuilder.build(event);
    final response = await _post(payload);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SlackTransportException(
        'Slack webhook returned HTTP ${response.statusCode}.',
        cause: response.body,
      );
    }
  }

  @override
  Future<void> dispose() async {
    _httpClient?.close();
  }

  Future<({int statusCode, String body})> _post(
    Map<String, dynamic> payload,
  ) async {
    final headers = const <String, String>{
      'content-type': 'application/json; charset=utf-8',
    };
    final body = jsonEncode(payload);

    try {
      if (_postOverride != null) {
        return await _postOverride!(webhookUrl, headers, body).timeout(timeout);
      }

      final client = _httpClient;
      if (client == null) {
        throw const SlackTransportException(
          'Slack transport is not initialized.',
        );
      }

      return await client.post(webhookUrl, headers, body).timeout(timeout);
    } on SlackTransportException {
      rethrow;
    } on TimeoutException catch (error) {
      throw SlackTransportException(
        'Slack webhook request timed out after $timeout.',
        cause: error,
      );
    } on Object catch (error) {
      throw SlackTransportException(
        'Slack webhook request failed.',
        cause: error,
      );
    }
  }
}
