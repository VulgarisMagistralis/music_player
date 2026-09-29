# Sync TODO: README, CLAUDE.md & Mempalace

## README.md Fixes

### Stale Checkboxes (mark incorrectly)

- [x] D1: Change `Sorting (title, artist, album, date added)` → `Sorting (name, duration, date modified)` — code only supports Name, Duration, DateModified via `SortBy` enum in Rust
- [ ] D2: Change `Filtering (duration, file size, extension)` from `[ ]` to partially done — duration filtering IS implemented (`IgnoredDurationThreshold` provider + scan threshold)
- [x] D3: Mark "Add/remove songs from playlists" as `[x]` — implemented via long-press menu + `addSongToTargetPlaylistProvider` / `removeSongFromTargetPlaylistProvider`
- [x] D5: Mark "Optional immersive mode" as `[x]` — implemented via `showAndroidNavigationButtonsProvider` + `SystemUiMode.edgeToEdge` in main.dart
- [ ] D6: Mark "Update check (manual)" back to `[ ]` — no update check code or button exists (only ARB string stubs)
- [ ] D7: Note that "Pause when hidden" toggle exists but handler is disconnected — dead setting
- [x] D8: Mark "Unit tests" as at least partially `[x]` — 24 test files exist across models/providers/utils/conversions

### Architecture Diagram Gaps

- [ ] Add WidgetBridge communication path (MethodChannel → MusicWidgetProvider.kt)
- [ ] Add AudioSessionManager layer
- [ ] Add Toast notification system
- [ ] Add Permission handling gateway

### Missing Features to Document

- [ ] Long-press context menu on songs (add to playlist, ignore, view details)
- [ ] Widescreen / dual-pane layout (screen > 900px → two-column with SongDetailsPanel)
- [ ] Automotive OS detection and adaptation (`isAutomotiveOSProvider`)
- [ ] Native splash screen + loading page with version info
- [ ] Toast notification system (`fluttertoast`)
- [ ] Permission handling gateway with error page routing
- [ ] Custom waveform loading animation (`WavePainter`)
- [ ] Album art caching and resizing pipeline
- [ ] Show/hide song icon toggle for songs without album art
- [ ] Widget background opacity slider

---

## CLAUDE.md Fixes

### Stale References

- [x] C1: Update "452 drawers" → **475 drawers** in music_player wing
- [ ] C2: Remove or update reference to `device_interaction.md` — file doesn't exist
  - If coordinates live in a mempalace drawer, point there instead
  - If deleted, remove the section

### Missing Documentation

- [ ] C3: Document Riverpod generator pattern (`@Riverpod(keepAlive: ...)`) + regenerate command
- [ ] C4: Document Freezed + JSON serialization pattern (`.freezed.dart` / `.g.dart` generation)
- [ ] C5: Document custom locale builder (`locale_generator_builder.dart`)
- [ ] C6: Document testing infrastructure (23 test files, mocktail/mockito, integration test entry point)
- [ ] C7: Document shell scripts: `bump_version.sh`, `push_music.sh`, `setup.sh`

---

## Mempalace

### Documentation Gap

- [x] M1: Added comprehensive project overview drawer to `documentation` room (`drawer_music_player_documentation_4a35ff52494ab08eebd48bba`)
- [x] M2: Evaluated — no MCP config needed. CLAUDE.md already covers all agent configuration (coding prefs, dev workflows, ADB procedures). No external MCP servers or tools in use beyond mempalace itself.

---

## Dev Tooling

### Deploy Script
- [x] Created `deploy.sh` — one-command build → install → launch. Uses FVM, supports both flavors.

  ```bash
  ./deploy.sh auto          # debug APK for Android Auto flavor (com.cenkt.music_player)
  ./deploy.sh automotive    # debug APK for Automotive OS flavor (com.cenkt.music_player.automotive)
  ./deploy.sh auto --hot    # flutter run --debug --flavor auto (hot reload)
  ./deploy.sh auto --release
  ```

- [x] Added structured debugging checklist to CLAUDE.md — reproducing, logcat filtering, screenshot capture, root cause identification, minimal fix, regenerate, re-test. Uses android-emulator-skill scripts for log monitoring.
