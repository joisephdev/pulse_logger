import 'dart:io';

import 'package:pulse_logger/pulse_logger.dart';

Future<void> main() async {
  final webhookUrl = Platform.environment['SLACK_WEBHOOK_URL'];

  final config = PulseConfig(
    environment: Platform.environment['APP_ENV'] ?? 'local',
    appName: 'Pulse Logger Example',
    minimumLevel: LogLevel.debug,
    defaultProperties: const <String, dynamic>{
      'team': 'mobile',
    },
    resolveProperties: () => const <String, dynamic>{
      'is_logged_in': true,
      'user_id': 'example-user',
      'language': 'en',
    },
    sensitiveKeys: const <String>[
      'email',
    ],
    sessionId: 'example-session',
    appVersion: '0.1.0',
  );

  final consoleTransport = const ConsoleTransport(useColor: false);

  final logger = webhookUrl == null || webhookUrl.isEmpty
      ? PulseLogger(config: config, transport: consoleTransport)
      : PulseLogger.multiChannel(
          config: config,
          transports: <Transport>[
            consoleTransport,
            SlackTransport(webhookUrl: webhookUrl),
          ],
          onError: (error, stackTrace) {
            // Keep observability on transport failures without breaking the app.
          },
        );

  await logger.info(
    event: 'user_login_started',
    title: 'User login started',
    message: 'The user selected Google as the authentication provider.',
    properties: const <String, dynamic>{
      'source': 'google',
      'email': 'person@example.com',
    },
  );

  await logger.warning(
    event: 'checkout_retry',
    title: 'Checkout retry scheduled',
    properties: const <String, dynamic>{
      'attempt': 2,
    },
  );

  try {
    throw StateError('Payment gateway rejected the request');
  } on Object catch (error, stackTrace) {
    await logger.error(
      event: 'payment_failed',
      title: 'Payment failed',
      message: 'The payment provider rejected the checkout request.',
      error: error,
      stackTrace: stackTrace,
      properties: const <String, dynamic>{
        'gateway': 'stripe',
        'amount': 49.99,
      },
    );
  }

  await logger.dispose();
}
