import 'dart:async';
import 'dart:convert';
import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

void main() {
  group('SlackTransport', () {
    test('posts JSON payloads to the webhook', () async {
      late Uri capturedUrl;
      late Map<String, String> capturedHeaders;
      late String capturedBody;
      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        post: (url, headers, body) async {
          capturedUrl = url;
          capturedHeaders = headers;
          capturedBody = body;
          return (statusCode: 200, body: 'ok');
        },
      );

      await transport.send(_event());

      expect(
        capturedUrl,
        Uri.parse('https://hooks.slack.com/services/test'),
      );
      expect(
        capturedHeaders['content-type'],
        'application/json; charset=utf-8',
      );
      final body = jsonDecode(capturedBody) as Map<String, dynamic>;
      expect(body['text'], '[ERROR] Payment failed');
      expect(body['attachments'], isA<List<dynamic>>());
      expect(body['blocks'], isA<List<dynamic>>());
    });

    test('throws on non-2xx responses', () async {
      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        post: (url, headers, body) async => (statusCode: 500, body: 'nope'),
      );

      await expectLater(
        transport.send(_event()),
        throwsA(isA<SlackTransportException>()),
      );
    });

    test('throws on network errors', () async {
      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        post: (url, headers, body) async => throw StateError('network down'),
      );

      await expectLater(
        transport.send(_event()),
        throwsA(isA<SlackTransportException>()),
      );
    });

    test('honors timeout', () async {
      Future<({int statusCode, String body})> neverResolve(
        Uri url,
        Map<String, String> headers,
        String body,
      ) async {
        await Completer<void>().future;
        return (statusCode: 200, body: 'ok');
      }

      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        timeout: const Duration(milliseconds: 1),
        post: neverResolve,
      );

      await expectLater(
        transport.send(_event()),
        throwsA(isA<SlackTransportException>()),
      );
    });

    test('dispose is a no-op when using an injected post override', () async {
      var called = false;
      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        post: (url, headers, body) async {
          called = true;
          return (statusCode: 200, body: 'ok');
        },
      );

      await transport.dispose();

      expect(called, isFalse);
    });
  });
}

LogEvent _event() {
  return LogEvent(
    event: 'payment_failed',
    title: 'Payment failed',
    level: LogLevel.error,
    timestamp: DateTime.utc(2026, 5, 1, 12, 30),
    environment: 'QA',
    appName: 'My App',
    properties: <String, dynamic>{'gateway': 'stripe'},
  );
}
