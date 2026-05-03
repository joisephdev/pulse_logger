import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pulse_logger/pulse_logger.dart';
import 'package:test/test.dart';

void main() {
  group('SlackTransport', () {
    test('posts JSON payloads to the webhook', () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('ok', 200);
      });
      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        client: client,
      );

      await transport.send(_event());

      expect(capturedRequest.method, 'POST');
      expect(
        capturedRequest.url,
        Uri.parse('https://hooks.slack.com/services/test'),
      );
      expect(
        capturedRequest.headers['content-type'],
        'application/json; charset=utf-8',
      );
      final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      expect(body['text'], '[ERROR] Payment failed');
      expect(body['attachments'], isA<List<dynamic>>());
      expect(body['blocks'], isA<List<dynamic>>());
    });

    test('throws on non-2xx responses', () async {
      final client = MockClient((request) async {
        return http.Response('nope', 500);
      });
      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        client: client,
      );

      await expectLater(
        transport.send(_event()),
        throwsA(isA<SlackTransportException>()),
      );
    });

    test('throws on network errors', () async {
      final client = MockClient((request) async {
        throw StateError('network down');
      });
      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        client: client,
      );

      await expectLater(
        transport.send(_event()),
        throwsA(isA<SlackTransportException>()),
      );
    });

    test('honors timeout', () async {
      final client = MockClient((request) async {
        await Completer<void>().future;
        return http.Response('ok', 200);
      });
      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        timeout: const Duration(milliseconds: 1),
        client: client,
      );

      await expectLater(
        transport.send(_event()),
        throwsA(isA<SlackTransportException>()),
      );
    });

    test('does not close injected clients on dispose', () async {
      var closed = false;
      final client = _ClosableMockClient(
        (request) async => http.Response('ok', 200),
        onClose: () => closed = true,
      );
      final transport = SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/test',
        client: client,
      );

      await transport.dispose();

      expect(closed, isFalse);
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

class _ClosableMockClient extends MockClient {
  _ClosableMockClient(super.fn, {required this.onClose});

  final void Function() onClose;

  @override
  void close() {
    onClose();
    super.close();
  }
}
