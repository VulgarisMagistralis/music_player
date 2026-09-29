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
- [x] Manual rescan (header icon on songs & playlist pages)
- [x] Support more formats
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
- [x] Add/remove songs from playlists
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
- [x] Optional immersive mode (system nav / notch handling)

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

```text
┌─────────────────────────────────────────────────────┐
│                   Flutter UI Layer                   │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────────┐ │
│  │  Pages      │ │   Providers  │ │ Audio Handler │ │
│  └──────┬──────┘ └──────┬───────┘ └──────┬───────┘ │
└─────────┼───────────────┼────────────────┼──────────┘
          │               │                │
┌─────────▼───────────────▼────────────────▼──────────┐
│              Riverpod Provider Container              │
└──────┬────────────────────┬──────────────────┬───────┘
       │                    │                  │
┌──────▼──────┐   ┌─────────▼───────┐  ┌───────▼──────┐
│ SharedPrefs │   │  Low-Level      │  │  Just Audio  │
│ (Settings)  │   │  Wrapper        │  │  AudioSessn  │
└─────────────┘   └────────┬────────┘  └──────────────┘
                           │
                 ┌─────────▼──────────┐
                 │   Rust Library     │
                 │ (SongCollection,   │
                 │  PlaylistColl,     │
                 │  ProcessMusic)     │
                 └────────────────────┘
```

## 🏗 Infrastructure & DevOps

### Local GitHub Actions Runner
This project uses a self-hosted runner for CI/CD pipelines.
- **Start Runner**: Navigate to `../actions-runner` and run `./run.sh`.
- **Terraform Workflow**: Managed via `.github/workflows/terraform.yml`. It triggers on changes in the `terraflow/` directory.
- **Linting**: Uses `tflint` installed via Go (`~/go/bin`).

### Kubernetes (K3s)
Infrastructure is deployed to a local K3s cluster.
- **Kubeconfig**: Located at `**/kubeconfig/kubeconfig.yaml`.
- **Namespace**: Core runner components reside in the `arc-runners` namespace.

---

A lightweight, offline MP3 player for Android.
Built with performance in mind and powered by Flutter and Rust.

- **Flutter (Riverpod for state management)**: Reactive, scalable state management for playback, library, and settings.
- **Rust core via FFI (`flutter_rust_bridge 2.11.1`)**: High-performance file indexing, metadata extraction, and playlist persistence.
- **Just Audio / Audio Service**: Foreground media session, background playback, interrupt handling, and Android Auto / notification controls.
- **Shared preferences with caching**: Fast, low-latency setting access with a singleton cache wrapper.
- **Optimistic UI updates**: Instant feedback for playlist/favourites changes with rollback on failure.

---

### 📖 Architecture Deep Dive

| Layer | Description |
|---|---|
| **Pages** | Feature screens: songs, favourites, playlists, search, settings, and shell navigation |
| **Providers** | Riverpod providers for songs, playlists, theme, settings, shuffle/repeat modes, and UI flags |
| **Audio Handler** | `PlayerAudioHandler` extending `BaseAudioHandler` with session restoration, custom actions (`toggle_shuffle`, `toggle_repeat`), and media browsing support |
| **Low-Level Wrapper** | Clean-architecture adapters over Rust calls for data sources and repositories |
| **Rust FFI** | Core library for media file scanning, song collection, playlist CRUD, and process music tasks |

---

### 🚀 Quick Start Checklist

- Run `dart run build_runner build --delete-conflicting-outputs` after modifying providers
- Run `dart run flutter_rust_bridge` after modifying Rust source files or `#[flutter_rust_bridge::frb()]` annotations
- Ensure `LowLevelInitializer.init()` is called before any Rust-bound provider is accessed
- Use `ref.read(provider.future)` in `initState`-like flows; prefer `ref.watch()` in widgets
- Always wrap Rust calls in `try/catch` or Riverpod error handling due to potential FFI boundary failures
- IDs from Rust are `BigInt` — never cast to `int`; use `BigInt.parse()` / `.toString()` carefully
- Keep Alive (`keepAlive: true`) on library/audio providers to prevent cold-start re-fetching

---

### 🧪 Testing & Quality

- [x] Unit tests
- [x] Media edge case handling
- [x] Android Auto DHU testing
- [ ] Large library stress tests

### 🧩 Planned

- [x] Home screen widget
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
