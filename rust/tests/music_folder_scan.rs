use lofty::file::{AudioFile, TaggedFileExt};
use lofty::tag::Accessor;
use rust_lib_music_player::api::data::{music_index::MusicIndex, song::Song};
use std::collections::{HashMap, HashSet};
use std::fs;
use std::path::PathBuf;

/// When `MUSIC_TEST_FOLDER=/your/music/dir` is set the test probes every audio
// file with lofty, builds Song structs, writes them to MusicIndex (sled), and
// prints a full scan report.  Without the env var a synthetic smoke-test runs so
// CI still sees the test pass.

fn try_folder() -> Option<PathBuf> {
    dotenv::dotenv().ok();
    if let Ok(p) = std::env::var("MUSIC_TEST_FOLDER") {
        let path = PathBuf::from(&p);
        if path.exists() && path.is_dir() {
            println!("[scan] Scanning: {}", path.display());
            return Some(path);
        }
    }
    None
}

fn synthesize_and_verify() {
    eprintln!("\n[scan] MUSIC_TEST_FOLDER not set — running synthetic smoke-test.");
    let dir = tempfile::tempdir().unwrap();
    let db_path = dir.path().join("smoke_db");
    let index = MusicIndex::new(db_path.to_str().unwrap());

    for i in 0..5u64 {
        let song = Song {
            id: i,
            path: format!("/fake/track_{}.mp3", i),
            title: format!("Song {}", i),
            artist: "Faker".into(),
            album: "Fake Album".into(),
            last_modified_at: 1000 + i as i64,
            duration: Some(120 + (i * 30) as u32),
            album_art_id: None,
        };
        index.add_song(&song);
    }

    let all = index.all_songs();
    assert_eq!(all.len(), 5);
    eprintln!("{} synthetic songs stored & retrieved.", all.len());
}

#[test]
fn music_folder_scan() {
    let folder = match try_folder() {
        Some(p) => p,
        None => {
            synthesize_and_verify();
            return;
        }
    };

    // ----- scan -----
    let allowed = ["mp3", "flac", "wav", "m4a", "ogg", "opus"];
    let mut tracks: Vec<Song> = Vec::new();
    let mut genres: HashMap<String, u32> = HashMap::new();
    let mut artists_set: HashSet<String> = HashSet::new();
    let mut albums_set: HashSet<String> = HashSet::new();
    let mut art_count: u32 = 0;
    let mut total_dur: u64 = 0;
    let mut scanned: u32 = 0;
    let mut skipped: u32 = 0;

    for entry in fs::read_dir(&folder).expect("read dir") {
        let entry = match entry {
            Ok(e) => e,
            Err(_) => continue,
        };
        let path = entry.path();
        if !path.is_file() {
            continue;
        }

        let ext = match path
            .extension()
            .and_then(|e| e.to_str())
            .map(|s| s.to_lowercase())
        {
            Some(e) => e,
            None => continue,
        };
        if !allowed.contains(&ext.as_str()) {
            continue;
        }

        let tf = match lofty::probe::Probe::open(&path) {
            Ok(p) => match p.read() {
                Ok(t) => t,
                Err(_) => {
                    skipped += 1;
                    continue;
                }
            },
            Err(_) => {
                skipped += 1;
                continue;
            }
        };

        scanned += 1;
        let path_s = path.to_string_lossy().to_string();
        let dur: u32 = tf.properties().duration().as_secs() as u32;
        total_dur += dur as u64;

        if let Some(tag) = tf.primary_tag() {
            let artist = tag.artist().map(|s| s.to_string()).unwrap_or_default();
            let album = tag.album().map(|s| s.to_string()).unwrap_or_default();
            let title = tag.title().map(|s| s.to_string()).unwrap_or_else(|| {
                path.file_stem()
                    .map(|s| s.to_string_lossy().to_string())
                    .unwrap_or("Unknown".into())
            });

            let has_art = !tag.pictures().is_empty();
            if has_art {
                art_count += 1;
            }

            if artist.is_empty() || album.is_empty() {
                continue;
            }

            artists_set.insert(artist.clone());
            albums_set.insert(album.clone());

            if let Some(tag_genre) = tag.genre().map(String::from) {
                *genres.entry(tag_genre).and_modify(|c| *c += 1).or_insert(1);
            }

            let song_id = xxhash_rust::xxh64::xxh64(path_s.as_bytes(), 0);

            // --- verify bincode roundtrip ---
            use bincode::config::standard;
            use bincode::{decode_from_slice, encode_to_vec};

            let raw = Song {
                id: song_id,
                path: path_s.clone(),
                title,
                artist,
                album,
                last_modified_at: 0,
                duration: Some(dur),
                album_art_id: has_art.then_some(song_id),
            };

            let b = encode_to_vec(&raw, standard()).unwrap();
            let (decoded, _): (Song, usize) = decode_from_slice(&b, standard()).unwrap();
            assert_eq!(decoded.id, raw.id);
            assert_eq!(decoded.title, raw.title);

            tracks.push(decoded);
        }
    }

    if scanned == 0 {
        eprintln!("[scan] No audio files found in {}", folder.display());
        return;
    }

    // ----- write to sled index & verify -----
    let tmp = tempfile::tempdir().unwrap();
    let idx_path = tmp.path().join("scan_i");
    let index = MusicIndex::new(idx_path.to_str().unwrap());
    for s in &tracks {
        index.add_song(s);
    }
    assert_eq!(index.all_songs().len(), tracks.len());

    // ----- print report -----
    eprintln!("\n  ╔═══════════════════ SCAN REPORT ═════════════════════╗");
    eprintln!("  Folder       : {}", folder.display());
    eprintln!("  Scanned      : {scanned} files");
    eprintln!("  Skipped      : {skipped} files");
    eprintln!("  With tags    : {} tracks", tracks.len());
    eprintln!("  Album art    : {art_count}");
    let hrs = total_dur / 3600;
    let min = (total_dur % 3600) / 60;
    eprintln!("  Duration     : {}h {:02}m ({})", hrs, min, total_dur);
    eprintln!("  Artists      : {}", artists_set.len());
    eprintln!("  Albums       : {}", albums_set.len());

    if !genres.is_empty() {
        let mut gv: Vec<_> = genres.into_iter().collect();
        gv.sort_by_key(|(_, c)| std::cmp::Reverse(*c));
        eprintln!("\n  ─ Genres (top 10)");
        for (n, c) in &gv[..gv.len().min(10)] {
            eprintln!("    {} | x{}", n, c);
        }
    }

    {
        let mut ac: HashMap<&str, u32> = HashMap::new();
        for s in &tracks {
            let mut counter = ac.entry(s.artist.as_str())
                .or_insert(0);
            *counter += 1;
        }
        let mut av: Vec<_> = ac.into_iter().collect();
        av.sort_by_key(|(_, c)| std::cmp::Reverse(*c));
        eprintln!("\n  ─ Top Artists (by track count)");
        for (n, c) in &av[..av.len().min(10)] {
            eprintln!("    {} | {} tracks", n, c);
        }
    }

    {
        let ds: Vec<u32> = tracks.iter().filter_map(|s| s.duration).collect();
        if !ds.is_empty() {
            let lo = *ds.iter().min().unwrap();
            let hi = *ds.iter().max().unwrap();
            let avg = ds.iter().sum::<u32>() as f64 / ds.len() as f64;
            eprintln!("\n  ─ Duration Stats");
            eprintln!("    Shortest : {}s", lo);
            eprintln!("    Longest  : {}s", hi);
            eprintln!("    Average  : {:.0}s", avg);

            let mut bk: HashMap<String, u32> = HashMap::new();
            for d in &ds {
                let _ = *bk
                    .entry(format!("[{}s]", (d / 60) * 60))
                    .and_modify(|c| *c += 1)
                    .or_insert(1);
            }
            let mut bkv: Vec<_> = bk.into_iter().collect();
            bkv.sort_by_key(|(k, _)| k.clone());
            eprintln!("\n  ─ Duration Buckets");
            for (label, count) in &bkv {
                eprintln!("    {:8} | {}", label, count);
            }
        }
    }

    eprintln!("  ╚══════════════════════════════════════════════════╝\n");
}
