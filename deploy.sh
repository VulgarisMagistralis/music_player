#!/usr/bin/env bash
# Quick build → install → launch for local testing.
# Usage: ./deploy.sh [auto|automotive] [--debug|--release] [--hot]
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Resolve fvm — try $PATH first, then common locations.
FVM_BIN=""
for candidate in "$(command -v fvm 2>/dev/null || true)" \
                  "$HOME/fvm/bin/fvm" \
                  "$HOME/.fvm/bin/fvm"; do
  if [ -x "$candidate" ]; then
    FVM_BIN="$candidate"
    break
  fi
done

if [ -z "$FVM_BIN" ]; then
  echo "✗ fvm not found on PATH or at ~/fvm/bin/fvm, ~./fvm/bin/fvm"; exit 1
fi
fvm() { "$FVM_BIN" "$@"; }

# ── Defaults ──────────────────────────────────────────────
FLAVOR="${1:-auto}"
MODE="${2:-}"
HOT="${3:-}"

# Parse optional flags that may appear in any position
for arg in "$@"; do
  case "$arg" in
    auto|automotive) FLAVOR="$arg" ;;
    --debug)   MODE="--debug"   ;;
    --release) MODE="--release" ;;
    --hot)     HOT="--hot";     MODE="--debug" ;;
  esac
done

case "$FLAVOR" in
  auto)       PACKAGE="com.cenkt.music_player" ;;
  automotive) PACKAGE="com.cenkt.music_player.automotive" ;;
  *) echo "Unknown flavor: $FLAVOR (use auto or automotive)"; exit 1 ;;
esac

echo "▸ Flavor: $FLAVOR  |  Package: $PACKAGE  |  Mode: ${MODE:-debug}"

# ── Pre-flight gate ───────────────────────────────────────
fvm flutter analyze --no-fatal-infos --no-fatal-warnings || {
  echo "⚠ analyze reported issues — proceeding anyway."
}
fvm flutter pub get

# ── Build & install ────────────────────────────────────────
if [ "$HOT" = "--hot" ]; then
  # Hot reload (fastest dev iteration, no build)
  cd "$PROJECT_DIR" && \
    fvm flutter run $MODE --flavor "$FLAVOR" -t lib/main.dart
else
  # Build APK and push to device
  cd "$PROJECT_DIR" && \
    fvm flutter build apk $MODE --flavor "$FLAVOR" && \
    adb install -r "build/app/outputs/flutter-apk/app-${FLAVOR}-debug.apk" || \
    adb install -r "build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk"

  # Launch
  echo "▸ Launching…"
  adb shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1
fi

echo "✓ Done."
