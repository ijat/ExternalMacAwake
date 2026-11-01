# Contributing

## Setup

Xcode 16.3 or later. No other dependencies.

```sh
make build
make test
make lint
```

`make format` fixes formatting; `make lint` is what CI runs. `make preview` renders the popover to
PNGs without launching the UI, which helps when you change a view. `make help` lists every target.

## Guidelines

- Keep `AwakeCore` free of SwiftUI and keep AppKit out of its public API. System access goes
  through a protocol with an adapter, so tests can use a fake.
- Add or update tests with the change. The controller and rules are tested with fakes; no test
  should touch the real displays or hold a real assertion.
- Never change system power settings (`pmset`, `defaults write` on system domains). The app only
  holds a power assertion, which macOS releases when the app exits.
- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`,
  `refactor:`, `test:`, `build:`, `ci:`, `chore:`.

## Pull request checklist

- [ ] `make lint` and `make test` pass
- [ ] New behaviour has a test
- [ ] README and `CHANGELOG.md` (under `[Unreleased]`) are updated when behaviour changes
- [ ] Commits follow Conventional Commits

## Releasing

1. Move the `[Unreleased]` notes in `CHANGELOG.md` under a new version heading and update
   `VERSION`.
2. Commit, then tag: `git tag v<version> && git push origin main v<version>`.
3. The Release workflow checks the tag against `VERSION`, runs the tests, builds the zip and
   publishes a GitHub release with `SHA256SUMS.txt`.
