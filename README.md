# pulse_logger

![pulse_logger logo](pulse_logger.png)

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
  pulse_logger: ^0.2.0
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
  message: 'The user selected Google as the authentication provider.',
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
  includePlatformContext: true,
  minimumLevel: LogLevel.info,
  defaultProperties: {
    'team': 'mobile',
  },
  resolveProperties: () => {
    'is_logged_in': true,
    'user_id': 'user-123',
  },
  sensitiveKeys: [
    'email',
    'phone',
  ],
  redactKeysBySubstring: true,
  sessionId: 'session-123',
  appVersion: '1.2.3',
  buildNumber: '42',
);
```

Important defaults:

- `enabled: true`
- `silentFailures: true`
- `includePlatformContext: true`
- `redactKeysBySubstring: true`
- `minimumLevel: LogLevel.debug`
- `timeout: Duration(seconds: 5)` on `PulseConfig`; Slack transport also accepts its own timeout.
- `defaultProperties: const {}`
- `sensitiveKeys: const []`

`webhookUrl` intentionally belongs to `SlackTransport`, not `PulseConfig`, so channel-specific secrets stay at the transport boundary.

`resolveProperties` is useful for dynamic context that changes while the app is running, such as the current user, locale, country, request id, or feature flag state. These values are merged into each event before sanitization, and explicit per-event properties can override them.

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

Matching is case-insensitive. By default, keys are also redacted when they contain a sensitive key fragment, so `firebase_id_token` is redacted because it contains `token`. Nested maps/lists are sanitized recursively.

Set `redactKeysBySubstring: false` if you need exact-key matching only.

## Failure Behavior

By default, `pulse_logger` should never break your app when event preparation or a transport fails.

```dart
final logger = PulseLogger(
  config: PulseConfig(
    environment: 'QA',
    appName: 'Checkout App',
    silentFailures: true,
  ),
  transport: SlackTransport(webhookUrl: webhookUrl),
  onError: (error, stackTrace) {
    // Optional visibility into event preparation or transport failures.
  },
);
```

For tests or debug tooling, set `silentFailures: false` to rethrow event preparation or transport failures.

## Flutter and App Context

`pulse_logger` stays Dart-first and does not depend on Flutter, GetX, or `package_info_plus`. Flutter apps should collect app-specific context in the host app and pass it into `PulseConfig`.

```dart
final config = PulseConfig(
  environment: envName,
  appName: appName,
  appVersion: packageInfo.version,
  buildNumber: packageInfo.buildNumber,
  resolveProperties: () {
    final profile = mainController.userProfile;

    return {
      'is_logged_in': mainController.isLoggedIn,
      'user_id': profile?.user.id,
      'user_email': profile?.user.email,
      'country_id': profile?.countryId,
      'language': mainController.currentLanguage,
    };
  },
);
```

This keeps the reusable package clean while preserving the richer context that an app-specific logger can provide.

## Flutter Web

The default `SlackTransport` implementation uses `dart:io` `HttpClient`, which is suitable for Dart VM, mobile, and desktop targets. For Flutter Web, provide the `post` override with a web-compatible HTTP implementation owned by your app:

```dart
final transport = SlackTransport(
  webhookUrl: webhookUrl,
  post: (url, headers, body) async {
    // Use your app's web-compatible HTTP client here.
    final response = await client.post(url, headers: headers, body: body);
    return (statusCode: response.statusCode, body: response.body);
  },
);
```

## Migrating From an App-specific Slack Logger

If you already have a custom `SlackLogger`, keep app-owned concepts in the app and map them into Pulse Logger:

- Event constants such as `SlackLogEvent.googleAuthStarted` can become app-owned string constants passed to `event:`.
- Environment configuration maps to `PulseConfig(environment: ..., appName: ..., minimumLevel: ...)`.
- User context previously read from a controller should move into `resolveProperties`.
- Long Slack body text should use `message`, while `title` stays short and human-readable.
- GetX or another DI framework can own a `PulseLogger` instance, but the package itself stays framework-neutral.

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

Included in `0.2.0`:

- Dart-only SDK.
- Console transport.
- Slack Incoming Webhook transport.
- Multi-transport fan-out.
- Sanitized event properties.
- Dynamic property enrichment.
- Optional platform context.
- Long-form event messages.
- Level filtering.
- Silent failure handling.

Deferred:

- Offline queue/buffer.
- Rate limiting.
- Dedupe windows.
- Flutter-specific helper package.
- Additional transports such as Discord or Telegram.
