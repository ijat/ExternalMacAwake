# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-11-01

### Added

- Menu-bar app (SwiftUI `MenuBarExtra`) that holds a display-sleep power assertion while a
  trigger holds, and releases it when it stops holding, when you switch it off, or when the app
  quits.
- Three selectable triggers: external display with the built-in display off (default), lid
  closed, and any external display.
- Popover showing state, connected displays, the keep-awake switch, the trigger picker and the
  launch-at-login switch.
- Launch at login, registered on first launch from a bundled app.
- `scripts/bundle.sh` and `make bundle`: universal (arm64 + x86_64), ad-hoc signed `.app`.
- CI (lint, test, bundle) and a tag-triggered release workflow on GitHub Actions.

[Unreleased]: https://github.com/ijat/ExternalMacAwake/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ijat/ExternalMacAwake/releases/tag/v0.1.0
