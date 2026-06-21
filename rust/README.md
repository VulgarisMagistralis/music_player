# Music Player - Rust Library

Shared Rust logic for the Flutter music player, exposed via flutter_rust_bridge.

## Tests

```bash
cargo test
```

### Real Music Folder Scan

Set `MUSIC_TEST_FOLDER` in `.env` (loaded automatically via dotenv) to scan an actual music directory:

```
MUSIC_TEST_FOLDER="/path/to/music"
```

Run with output visible:

```bash
cargo test music_folder_scan -- --nocapture
```

Without the env var, a synthetic smoke-test runs instead so CI always passes.

## Generating Dart Bindings

After modifying Rust sources or `#[flutter_rust_bridge::frb()]` annotations:

```bash
dart run flutter_rust_bridge
```
