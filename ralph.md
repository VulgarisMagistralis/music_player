# GUI Emulator Testing Guide for Ralph
Fix home screen widget to keep song and theme states in accord with app's states
## 1. Build & Deployment
- Always use `fvm flutter` instead of `flutter`.
- **Fastest Dev Iteration (Hot Reload):**
  - Android Auto: `./deploy.sh auto --hot`
  - Automotive: `./deploy.sh automotive --hot`
- **Full Build & Install:**
  - `./deploy.sh auto`
  - `./deploy.sh automotive`
- **Pre-test Gate (Run before deploying):**
  `fvm flutter analyze --no-fatal-infos --no-fatal-warnings && fvm dart run build_runner build --delete-conflicting-outputs && fvm flutter test`

## 2. Debugging & Log Monitoring
- **Filtered Logcat (Error level):**
  `python ~/.claude/skills/android-emulator-skill/scripts/log_monitor.py --app com.cenkt.music_player --severity error`
- **App State Snapshot (Screenshot + UI Hierarchy + Logs):**
  `python ~/.claude/skills/android-emulator-skill/scripts/app_state_capture.py --package com.cenkt.music_player`

## 3. UI Inspection
- **Semantic UI Element Listing:**
  `python ~/.claude/skills/android-emulator-skill/scripts/screen_mapper.py`
- **Manual XML Layout Dump:**
  1. `adb shell uiautomator dump /storage/emulated/0/view.xml`
  2. `adb pull /storage/emulated/0/view.xml dump3.xml`
- **Quick Screenshot:**
  `adb exec-out screencap -p > screenshot.png`

## 4. Interaction & Navigation
- **Semantic Navigation (Tap by text/type/ID):**
  `python ~/.claude/skills/android-emulator-skill/scripts/navigator.py`
- **Gestures (Swipes, Scrolls, Long Presses):**
  `python ~/.claude/skills/android-emulator-skill/scripts/gesture.py`
- **Raw ADB Taps (Pixel-based):**
  `adb shell input tap <x> <y>`

### ⚠️ Critical Interaction Rules
- **Wait ~1.5s between taps** to prevent "double-tap" issues (where a switch toggles twice).
- **Execute taps sequentially**, not in parallel.
- For batch operations, chain with `&&` and `sleep 1.5`.

## 5. Android Auto (DHU)
- **Start DHU:** `~/Android/Sdk/extras/google/auto ./desktop-head-unit --usb`
- **Package ID:** `com.cenkt.music_player`
