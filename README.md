# Music Player

A lightweight, offline MP3 player for Android.
Built with performance in mind and powered by Flutter and Rust.

## Features

### ✅ Core Playback (MVP)

- [x] Local MP3 playback
- [x] Background audio playback
- [x] Media notification controls
- [x] Lock screen controls
- [x] Basic player UI (play / pause / next / previous)
- [x] Playback state persistence (resume last song)
- [x] Seek bar improvements

### 📂 Library & Media Scanning

- [x] Local file scanning
- [x] Display all songs
- [x] Folder selection for scanning
- [x] Sorting (title, artist, album, date added)
- [ ] Manual rescan
- [ ] Support more formats
- [ ] Quick scan (recent changes only)
- [ ] Filtering (duration, file size, extension)
- [ ] Large library performance optimizations

### ⭐ Favourites & Playlists

- [x] Mark songs as favourites
- [x] Favourites view
- [x] Create playlists
- [ ] Edit / reorder playlists
- [ ] Add/remove songs from playlists
- [ ] Smart playlists (recently added, most played)

### 🎨 UI & Customization

- [x] Material-based UI
- [x] Theme color selection
- [ ] Font size slider
- [ ] Icon size adjustment
- [ ] Optional immersive mode (system nav / notch handling)

### 🚗 Android Auto & External Controls

- [x] Android Auto support
- [x] Auto-play on Bluetooth connect
- [x] Auto-play on USB connect
- [ ] Headphone button controls

### 🧪 Testing & Quality

- [ ] Unit tests
- [ ] Media edge case handling
- [x] Android Auto DHU testing
- [ ] Large library stress tests

### 🛠 Architecture & Performance

- [x] Rust core integration
- [x] Rust-powered media indexing
- [ ] Parallel media scanning
- [ ] Memory usage optimizations
- [ ] Crash recovery handling

### ⚙️ Settings

- [x] Basic settings screen
- [x] Scan folder management
- [ ] Media scan criteria
- [ ] Playback behavior settings
- [ ] Update check (maybe, manual only)

### 🧩 Miscellaneous

- [ ] Home screen widget
- [ ] Multi-language support
- [ ] Metadata editing

### 📝 Project Status

This app is in early development.
APIs, UI, and features may change frequently.

Android auto test:
https://developer.android.com/training/cars/testing/dhu#connection-aoap
~/Android/Sdk/extras/google/auto  ./desktop-head-unit --usb
