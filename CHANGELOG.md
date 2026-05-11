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

## [0.2.1] - 2026-05-11

### Documentation

- Documented this release in `CHANGELOG.md` to match `pubspec.yaml` for pub.dev validation.
- Aligned install example in `README.md` with `0.2.1`.

## [0.2.0] - 2026-05-11

### Added

- Added optional long-form event messages that Slack and console transports can render separately from the event title.
- Added dynamic property enrichment through `PulseConfig.resolveProperties`, allowing host apps to attach current user/session context without coupling `pulse_logger` to Flutter.
- Added runtime platform context collection behind `PulseConfig.includePlatformContext`.
- Added fragment-aware sensitive key matching through `PulseConfig.redactKeysBySubstring`.

### Changed

- `PulseLogger` now applies the existing silent failure and `onError` policy to event preparation failures as well as transport failures.
- Isolated the default Slack HTTP client behind platform-specific internals so web consumers can compile when they provide the `post` override.
- Updated README and example coverage for migration from an app-specific Slack logger, Flutter Web transport overrides, and richer event context.

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

[Unreleased]: https://github.com/joisephdev/pulse_logger/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/joisephdev/pulse_logger/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/joisephdev/pulse_logger/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/joisephdev/pulse_logger/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/joisephdev/pulse_logger/releases/tag/v0.1.0
