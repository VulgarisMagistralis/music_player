# Music Player

A lightweight, offline MP3 player for Android.
Built with performance in mind and powered by Flutter and Rust.

## Features

### ✅ Core Playback

- [x] Local MP3 playback
- [x] Background audio playback
- [x] Media notification controls
- [x] Lock screen controls
- [x] Player UI (play / pause / next / previous / stop)
- [x] Playback state persistence (resume last song)
- [x] Seek bar with buffered position display
- [x] Shuffle and repeat modes
- [x] Rewind / fast-forward with configurable intervals

### 📂 Library & Media Scanning

- [x] Local file scanning (Rust-powered indexing)
- [x] Display all songs with album art
- [x] Folder selection for scanning
- [x] Sorting (title, artist, album, date added)
- [ ] Manual rescan
- [ ] Support more formats
- [ ] Quick scan (recent changes only)
- [ ] Filtering (duration, file size, extension)
- [ ] Large library performance optimizations

### 🔍 Search

- [x] Search by title, artist, or album (case-insensitive)
- [x] Real-time filter as you type

### ⭐ Favourites & Playlists

- [x] Mark songs as favourites
- [x] Favourites view
- [x] Create playlists
- [x] Delete playlists
- [ ] Edit / reorder playlists
- [ ] Add/remove songs from playlists
- [ ] Smart playlists (recently added, most played)

### 🎨 UI & Customization

- [x] Material-based UI
- [x] Theme mode (light / dark)
- [x] Theme colors (background, text, accent)
- [x] Font size adjustment
- [x] Icon size adjustment
- [x] Bottom navigation bar (songs, favourites, playlists, search, settings)
- [x] Skeleton loading states
- [x] Song info sheet
- [ ] Optional immersive mode (system nav / notch handling)

### 🌐 Localization

- [x] English
- [x] German
- [x] Spanish
- [x] French
- [x] Italian
- [x] Japanese
- [x] Korean
- [x] Portuguese
- [x] Russian
- [x] Chinese (Simplified)

### 🚗 Android Auto & External Controls

- [x] Android Auto support
- [x] Auto-play on Bluetooth connect
- [x] Auto-play on USB connect
- [x] Pause on disconnect
- [ ] Headphone button controls

### ⚙️ Settings

- [x] Scan folder management (add / remove folders)
- [x] Appearance (theme mode, colors, font/icon size)
- [x] Behavior toggles (pause when muted, pause when hidden)
- [x] Playback intervals (rewind / fast-forward)
- [x] Language selection
- [x] Version display
- [x] Update check (manual)
- [ ] Media scan criteria

### 🛠 Architecture

- Flutter (Riverpod for state management)
- Rust core via FFI (media indexing, database operations)
- SQLite for song and playlist storage
- `just_audio` / `audio_service` for playback and background audio
- Shared preferences with caching for settings

### 🧪 Testing & Quality

- [ ] Unit tests
- [ ] Media edge case handling
- [x] Android Auto DHU testing
- [ ] Large library stress tests

### 🧩 Planned

- [ ] Home screen widget
- [ ] Metadata editing
- [ ] Crash recovery handling

---

### Project Status

This app is in active development. APIs, UI, and features may change frequently.

#### Android Auto DHU Testing

```bash
# From your SDK directory:
~/Android/Sdk/extras/google/auto  ./desktop-head-unit --usb
```

See: https://developer.android.com/training/cars/testing/dhu#connection-aoap
