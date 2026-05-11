# AGENTS.md

## Project

- Name: `pulse_logger`
- Type: Dart package for pub.dev
- Goal: operational event logging with structured events, sanitization, Slack transport, console transport, multi-transport fan-out, and a simple public facade.

## Working Style

- Keep the package Dart-first unless there is an explicit decision to create a separate Flutter companion package.
- Preserve the public API shape carefully. `PulseLogger`, `PulseConfig`, `LogEvent`, `LogLevel`, `Transport`, `PulseMultiTransport`, `ConsoleTransport`, `SlackPayloadBuilder`, and `SlackTransport` are part of the public surface.
- Keep internal helpers internal unless there is a strong reason to expose them. `DataSanitizer` should remain internal by default.
- Prefer small, composable additions over adding framework-heavy abstractions.

## Git attribution

- Never set **Cursor** (or similar tooling accounts) as **author** or **committer**.
- Never add **`Co-authored-by: Cursor`** (or variants) to commit messages.

## Quality Gates

Before considering work complete, run:

```bash
dart format --set-exit-if-changed .
dart analyze
dart test
```

When validating release readiness, also run:

```bash
dart doc --validate-links
dart pub outdated --json
dart pub publish --dry-run
```

## Documentation Rules

- Every public class, typedef, constructor, field, and method should keep `///` dartdoc comments.
- `README.md` must stay aligned with the actual public API.
- `example/example.dart` must remain runnable and reflect the preferred usage patterns.

## Release Rules

Before publishing a new version:

1. Update `version:` in `pubspec.yaml`.
2. Update `CHANGELOG.md` for that exact version.
3. Verify `README.md` and `example/example.dart` still match the current API.
4. Run all quality gates and release-readiness checks.
5. Publish only from a clean git state.

## Changelog Requirement

- Never publish a new version without updating `CHANGELOG.md`.
- Every version bump must have a corresponding changelog section.
- The changelog entry should summarize:
  - new features
  - fixes
  - breaking changes if any
  - deferred items if relevant to release expectations

## pub.dev Notes

- Keep `.pubignore` updated so local agent or generated artifacts are not published.
- Avoid adding dependencies unless they materially improve the package.
- Prefer stable, low-friction package metadata in `pubspec.yaml`.
- Keep a real `repository` and `issue_tracker` URL in `pubspec.yaml` before release.

## CI / Release Workflow

This project uses two workflows:

- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`

Expected flow:

1. CI validates formatting, analysis, tests, coverage, and publish dry-run on PRs.
2. Release workflow creates a tag, a GitHub Release, and runs `dart pub publish --force` to pub.dev (OIDC) after a PR to `main` is merged, or when run manually (`workflow_dispatch`).

## Known Deferred Items

These are known non-blocking items currently deferred beyond `0.1.x` unless reprioritized:

- value equality for `LogEvent` and `PulseConfig`
- more direct observability around internally owned Slack HTTP client disposal
- rate limiting
- dedupe windows
- offline buffering
- Flutter-specific companion package

## Product Direction

High-value growth areas already identified:

- rate limiting and deduplication
- generic webhook transport
- context/scoped logging
- correlation IDs
- offline retry buffer
- Flutter companion package

See also:

- `.agents/ideas.md`
- `.agents/sprint-forge/pulse_logger/ROADMAP.md`
