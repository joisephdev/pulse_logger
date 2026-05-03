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

## [0.1.1] - 2026-05-03

### Changed

- Replaced the Slack transport runtime dependency on `package:http` with a `dart:io` implementation based on `HttpClient`.
- Tightened publish readiness for pub.dev by keeping generated and local-only artifacts out of the published archive.
- Added project-level release guidance in `AGENTS.md`, including the requirement to update `CHANGELOG.md` before each new published version.

### Documentation

- Added the package logo to the README.
- Expanded release and workflow documentation for CI, tagging, and pub.dev publishing.

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

[Unreleased]: https://github.com/joicodev/pulse_logger/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/joicodev/pulse_logger/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/joicodev/pulse_logger/releases/tag/v0.1.0
