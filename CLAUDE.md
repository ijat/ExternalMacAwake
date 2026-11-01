# ExternalMacAwake

macOS menu-bar app (SwiftUI, Swift 6, macOS 14+) that holds a display-sleep power assertion while a
selectable trigger holds. Default trigger: external display online and the built-in display off.

## Map

- `Sources/AwakeCore/`: UI-free logic. `Triggers/` (rules, `TriggerCatalog`), `System/` (provider
  protocols + IOKit/CoreGraphics adapters), `Settings/`, `AwakeController.swift`.
- `Sources/ExternalMacAwake/`: SwiftUI app. `main.swift` (also handles `--render-preview <dir>`),
  `ExternalMacAwakeApp.swift`, `AppDelegate.swift`, `Views/`, `Services/LoginItemService.swift`,
  `StatusIcon.swift`, `Preview/`.
- `Tests/AwakeCoreTests/`: tests with fakes (`Fixtures.swift`).
- `Resources/Info.plist`, `scripts/bundle.sh`, `VERSION`, `Makefile`, `.github/workflows/`.

## Commands

- `make build`, `make test`, `make lint`, `make format`
- `make bundle` (universal ad-hoc signed `build/ExternalMacAwake.app`), `make zip`, `make preview`
- Verify the assertion with `pmset -g assertions | grep ExternalMacAwake`

## Conventions

- `AwakeCore` stays UI-free: no SwiftUI, and AppKit only inside adapter internals, never in the
  public API.
- All system access (displays, lid, power assertion, settings, login item) is behind a protocol so
  tests use fakes. Tests must not touch real displays or hold a real assertion.
- Never use `pmset` or write system settings. The only mechanism is the IOPM assertion, so quitting
  or crashing restores normal behaviour. The quit path must call `controller.shutdown()`.
- Format with `swift format` (`.swift-format`); `make lint` must pass.
- The popover uses a pure-SwiftUI switch (`SwitchToggleStyle`) so `ImageRenderer` previews render.
- Needs Swift 6.2+ / Xcode 26 (`isolated deinit`); CI and release workflows select Xcode 26
  explicitly. Strict concurrency; system protocols are `@MainActor`.
- Conventional commits. Keep `README.md` and `CHANGELOG.md` in step with behaviour.

## Adding a trigger

New `TriggerRule` in `Triggers/BuiltInRules.swift`, list it in `TriggerCatalog.standard`, add rows to
`TriggerRuleTests`, document it in the README triggers table.

## Release

Update `VERSION` and `CHANGELOG.md`, commit, tag `v<VERSION>` and push the tag. `release.yml`
verifies the tag matches `VERSION`, tests, bundles and publishes the zip with `SHA256SUMS.txt`.
The app is ad-hoc signed and not notarized; never claim otherwise.
