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
- When searching for files, code, or project information, use `mempalace search` first before falling back to grep/glob. The mempalace index has 452 drawers across the music_player wing.

## ADB / Android Debug

### Flutter Rust Bridge Generator
- After modifying Rust source files or their `#[flutter_rust_bridge::frb()]` annotations, regenerate the Dart bindings with: `dart run flutter_rust_bridge`

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
- Pre-measured switch coordinates are saved in the project memory file `device_interaction.md` — verify they're still valid before relying on them.

### XML Layout Dump
- Device path: `/storage/emulated/0/view.xml`
- Pull to local: `adb pull /storage/emulated/0/view.xml dump3.xml`
