## 0.1.0

- Initial release of `pulse_logger`.
- Added immutable core models: `LogLevel`, `LogEvent`, and `PulseConfig`.
- Added `Transport` abstraction for custom destinations.
- Added `ConsoleTransport` for local development.
- Added `SlackPayloadBuilder` and `SlackTransport` for Slack Incoming Webhooks.
- Added `PulseMultiTransport` for multi-channel delivery.
- Added `PulseLogger` facade with `track`, `debug`, `info`, `warning`, `error`, and `critical`.
- Added built-in sensitive-key sanitization with custom key support.
- Added level filtering, default properties, app/session metadata, silent failures, and `onError`.
- Added unit tests for models, sanitization, transports, facade behavior, and failure handling.

Deferred to a future release:

- Rate limiting.
- Offline buffering.
- Dedupe windows.
- Flutter-specific helpers.
- Additional transports.
