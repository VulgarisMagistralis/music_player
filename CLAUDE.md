# Music Player Project

## Coding Preferences

### Bug Fixes
- Always attempt minimal changes first before rewriting entire files
- Identify the specific problematic line(s) and fix only those
- Preserve existing patterns, variable names, and structure unless they are the cause of the bug

### General Approach
- Read the affected file first before making changes
- When a widget throws a layout error, check the widget hierarchy and constraint conflicts
- Flutter layout issues often stem from `width: double.infinity` or similar infinite constraints inside scrollable/Expanded contexts

## Local Project Search
- When searching for files, code, or project information, use `mempalace search` first before falling back to grep/glob. The mempalace index has 475 drawers across the music_player wing.

## Dev Commands — always use `fvm flutter`, never bare `flutter`

### Build & Deploy
- **Deploy script:** `./deploy.sh [auto|automotive] [--debug|--release|--hot]` — one-command build → install → launch
  - `./deploy.sh auto --hot` — fastest dev iteration, hot reload, Android Auto flavor (`com.cenkt.music_player`)
  - `./deploy.sh automotive --hot` — fastest dev iteration, Automotive OS flavor (`com.cenkt.music_player.automotive`)
  - `./deploy.sh auto` — builds debug APK, installs, launches
- **Manual build:** `fvm flutter build apk --debug --flavor auto`

### Code Generation (after editing)
- Riverpod providers / Freezed models / JSON serializers: `fvm dart run build_runner build --delete-conflicting-outputs`
- Rust bridge bindings: `fvm dart run flutter_rust_bridge`
- Both may be needed — check what you changed

### Pre-test Gate (run before deploying to device)
```bash
fvm flutter analyze --no-fatal-infos --no-fatal-warnings && fvm dart run build_runner build --delete-conflicting-outputs && fvm flutter test
```

### Flavor Reference
| Flavor | Package ID | Use case |
|--------|-----------|----------|
| `auto` | `com.cenkt.music_player` | Android Auto (phone + AA support) |
| `automotive` | `com.cenkt.music_player.automotive` | Android Automotive OS (stand-alone head unit) |

### Package Names for ADB/monkey
- **Auto:** `adb shell monkey -p com.cenkt.music_player -c android.intent.category.LAUNCHER 1`
- **Automotive:** `adb shell monkey -p com.cenkt.music_player.automotive -c android.intent.category.LAUNCHER 1`

### Shell Scripts (project root)
- `deploy.sh` — build → install → launch (see above)
- `push_music.sh` — pushes media files to device via MediaStore (AAOS multi-user testing)
- `bump_version.sh` — increments pubspec version code

## Code Generation Patterns

### Riverpod Generator
- All providers use `@Riverpod(keepAlive: true)` annotation pattern (default). A few explicit `keepAlive: false`: permission provider, one-shot Rust ops.
- Generated output: `.g.dart` alongside source
- Regenerate: `fvm dart run build_runner build --delete-conflicting-outputs`

### Freezed + JSON Serialization
- Immutable data models use `@freezed` + `@JsonSerializable`. Generated: `.freezed.dart`, `.g.dart`
- Same regenerate command as Riverpod above

### Flutter Rust Bridge
- FFI bridge via `flutter_rust_bridge 2.13.0`. Regenerate after any Rust source or `#[frb()]` annotation change.

## Testing Infrastructure
- 24 test files in `test/` (models/providers/utils/conversions) using mocktail + mockito
- Integration test entry point: `test_driver/integration_test.dart`
- Audio fixtures: `test_audio/` (5 MP3 files)

## Debugging Checklist

When diagnosing a failure in the running app, follow this order:

1. **Reproduce** — verify the issue is consistent before investigating further
2. **`adb logcat`** — filter for this package (`python ~/.claude/skills/android-emulator-skill/scripts/log_monitor.py --app com.cenkt.music_player --severity error`)
3. **Screenshot** — `adb exec-out screencap -p` or the emulator skill's screenshot utility
4. **Identify source** — is it Flutter (widget/layout/render), Android (permission/manifest/NativeMethodChannel), network, or test setup?
5. **Make smallest fix** — edit only the affected widget/provider/logic line(s)
6. **Regenerate if needed** — run `fvm dart run build_runner build --delete-conflicting-outputs` (Riverpod/Freezed) and/or `fvm dart run flutter_rust_bridge` (Rust bridge)
7. **Re-test** — verify the fix on device before moving on

## ADB / Android Debug

### Proven tap-and-verify workflow
The tested method for interacting with UI on the connected device:

1. **Dump layout:** `adb shell uiautomator dump /storage/emulated/0/view.xml`
2. **Pull to local:** `adb pull /storage/emulated/0/view.xml dump3.xml`
3. **Read XML** to find widget bounds → calculate tap center
4. **Tap:** `adb shell input tap <x> <y>`
5. **Verify immediately** with screenshot: `adb exec-out screencap -p` (faster than re-dumping XML)

### Switch Automation — important gotchas
- **Always wait ~1.5s between taps** — faster intervals cause double-taps (switch toggles then immediately toggles back). This has been observed in practice.
- **Fire taps sequentially, not in parallel** — each `adb shell input tap` should complete before the next starts.
- For batch operations, chain with `&&` and `sleep 1.5` between commands.

### XML Layout Dump
- Device path: `/storage/emulated/0/view.xml`
- Pull to local: `adb pull /storage/emulated/0/view.xml dump3.xml`

### Android Emulator Skill (available)
Python scripts at `~/.claude/skills/android-emulator-skill/scripts/`. Key ones:
- `screen_mapper.py` — semantic UI element listing of current screen
- `navigator.py` — find and tap elements by text/type/ID (not pixel coords)
- `log_monitor.py --app com.cenkt.music_player` — filtered logcat for this app
- `app_state_capture.py --package com.cenkt.music_player` — screenshot + UI hierarchy + logs snapshot
- `gesture.py` — swipes, scrolls, long presses
- **Always handle permission dialogs (e.g., music/audio access) during app launch.**
