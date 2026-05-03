# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned

- Rate limiting.
- Offline buffering.
- Dedupe windows.
- Flutter-specific helpers.
- Additional transports.

## [0.1.0] - 2026-05-02

### Added

- Initial public release of `pulse_logger`.
- Immutable core models: `LogLevel`, `LogEvent`, and `PulseConfig`.
- `Transport` abstraction for custom destinations.
- `ConsoleTransport` for local development.
- `SlackPayloadBuilder` and `SlackTransport` for Slack Incoming Webhooks.
- `PulseMultiTransport` for multi-channel delivery.
- `PulseLogger` facade with `track`, `debug`, `info`, `warning`, `error`, and `critical`.
- Built-in sensitive-key sanitization with custom key support.
- Level filtering, default properties, app/session metadata, silent failures, and `onError`.
- Unit tests for models, sanitization, transports, facade behavior, and failure handling.

[Unreleased]: https://github.com/joicodev/pulse_logger/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/joicodev/pulse_logger/releases/tag/v0.1.0
