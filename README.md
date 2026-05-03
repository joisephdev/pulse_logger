# pulse_logger

`pulse_logger` is a Dart-first operational event logger for apps that need lightweight process tracing, QA/production debugging, and alert-style event delivery without adopting a full analytics stack.

It gives you a small SDK-style API:

- `logger.track(...)`
- `logger.debug(...)`
- `logger.info(...)`
- `logger.warning(...)`
- `logger.error(...)`
- `logger.critical(...)`

The first built-in transports are:

- `ConsoleTransport` for local development.
- `SlackTransport` for Slack Incoming Webhooks.
- `PulseMultiTransport` for sending the same event to multiple destinations.

## Install

```yaml
dependencies:
  pulse_logger: ^0.1.0
```

```dart
import 'package:pulse_logger/pulse_logger.dart';
```

## Quick Start

```dart
final logger = PulseLogger(
  config: PulseConfig(
    environment: 'QA',
    appName: 'Checkout App',
  ),
  transport: const ConsoleTransport(),
);

await logger.info(
  event: 'user_login_started',
  title: 'User login started',
  properties: {
    'source': 'google',
  },
);
```

## Slack

```dart
final logger = PulseLogger(
  config: PulseConfig(
    environment: 'production',
    appName: 'Checkout App',
    minimumLevel: LogLevel.warning,
  ),
  transport: SlackTransport(
    webhookUrl: 'https://hooks.slack.com/services/...',
  ),
);

await logger.error(
  event: 'payment_failed',
  title: 'Payment failed',
  error: error,
  stackTrace: stackTrace,
  properties: {
    'gateway': 'stripe',
    'amount': 49.99,
  },
);
```

## Multi-channel Logging

```dart
final logger = PulseLogger.multiChannel(
  config: PulseConfig(
    environment: 'QA',
    appName: 'Checkout App',
  ),
  transports: [
    const ConsoleTransport(),
    SlackTransport(webhookUrl: webhookUrl),
  ],
);
```

## Configuration

```dart
final config = PulseConfig(
  environment: 'QA',
  appName: 'Checkout App',
  enabled: true,
  silentFailures: true,
  minimumLevel: LogLevel.info,
  defaultProperties: {
    'team': 'mobile',
  },
  sensitiveKeys: [
    'email',
    'phone',
  ],
  sessionId: 'session-123',
  appVersion: '1.2.3',
  buildNumber: '42',
);
```

Important defaults:

- `enabled: true`
- `silentFailures: true`
- `minimumLevel: LogLevel.debug`
- `timeout: Duration(seconds: 5)` on `PulseConfig`; Slack transport also accepts its own timeout.
- `defaultProperties: const {}`
- `sensitiveKeys: const []`

`webhookUrl` intentionally belongs to `SlackTransport`, not `PulseConfig`, so channel-specific secrets stay at the transport boundary.

## Sanitization

Event properties are sanitized before transport delivery. Built-in keys include:

- `token`
- `access_token`
- `refresh_token`
- `authorization`
- `password`
- `secret`
- `webhook`
- `credential`
- `card_number`
- `cvv`
- `api_key`
- `private_key`

Custom keys can be added with `PulseConfig.sensitiveKeys`.

```dart
final config = PulseConfig(
  environment: 'QA',
  appName: 'Checkout App',
  sensitiveKeys: ['email'],
);
```

Matching is case-insensitive and nested maps/lists are sanitized recursively.

## Failure Behavior

By default, `pulse_logger` should never break your app when a transport fails.

```dart
final logger = PulseLogger(
  config: PulseConfig(
    environment: 'QA',
    appName: 'Checkout App',
    silentFailures: true,
  ),
  transport: SlackTransport(webhookUrl: webhookUrl),
  onError: (error, stackTrace) {
    // Optional visibility into transport failures.
  },
);
```

For tests or debug tooling, set `silentFailures: false` to rethrow transport failures.

## Security Notice for Mobile Apps

Do not treat Slack Incoming Webhook URLs as secure secrets when embedded directly in Flutter or other mobile binaries. A webhook URL shipped inside a public app can be extracted from the binary by a motivated user.

`pulse_logger` helps reduce risk with sanitization, level filtering, and silent failure behavior, but it does not make embedded mobile secrets safe.

For sensitive production use, prefer this architecture:

```text
Flutter app -> your backend/serverless proxy -> Slack Incoming Webhook
```

Your proxy can enforce authentication, rate limits, payload validation, environment rules, and webhook rotation without shipping the Slack webhook URL to clients.

## How This Differs From `package:logger`

`package:logger` is great for local/log formatting workflows. `pulse_logger` is focused on operational event delivery: named events, levels, structured metadata, sanitization, and transport routing to destinations such as Slack.

## Current Scope

Included in `0.1.0`:

- Dart-only SDK.
- Console transport.
- Slack Incoming Webhook transport.
- Multi-transport fan-out.
- Sanitized event properties.
- Level filtering.
- Silent failure handling.

Deferred:

- Offline queue/buffer.
- Rate limiting.
- Dedupe windows.
- Flutter-specific helper package.
- Additional transports such as Discord or Telegram.

# pulse_logger
