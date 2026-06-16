use crate::api::data::song::Song;
use crate::api::data::stream_event::StreamEvent;
use crate::api::music_folder::get_music_folder_list;
use crate::api::music_folder::get_thumbnails_dir;
use crate::api::song_collection::locked_song_collection;
use crate::api::utils::hash::hash_string;
use crate::frb_generated::StreamSink;
use futures::StreamExt;
use lofty::file::AudioFile;
use lofty::file::TaggedFileExt;
use lofty::probe::Probe;
use lofty::tag::Accessor;
use log::info;
use std::borrow::Cow;
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use tokio::task::spawn;

#[flutter_rust_bridge::frb()]
pub async fn read_music_files(sink: StreamSink<StreamEvent>, min_duration_s: u32) {
    spawn(async move {
        let thumbnails_dir = match get_thumbnails_dir() {
            Ok(f) => f,
            Err(_) => {
                let _ = sink.add(StreamEvent::Error("Failed to fetch folder".into()));
                return;
            }
        };

        let folders = match get_music_folder_list() {
            Ok(f) => f,
            Err(_) => {
                let _ = sink.add(StreamEvent::Error("Failed to fetch folder".into()));
                return;
            }
        };

        if folders.is_empty() {
            let _ = locked_song_collection().remove_all_songs();
            let _ = sink.add(StreamEvent::Done);
            return;
        }
        let existing: HashMap<u64, i64> = {
            let collection = locked_song_collection();
            collection
                .get_all_songs()
                .into_iter()
                .map(|s| (s.id, s.last_modified_at))
                .collect()
        };
        let mut all_paths: Vec<PathBuf> = Vec::new();
        for folder in &folders {
            let dir = PathBuf::from(folder);
            info!("SCAN CHECK: {} exists={} is_dir={}", dir.display(), dir.exists(), dir.is_dir());
            if !dir.exists() || !dir.is_dir() {
                let _ = sink.add(StreamEvent::Error(format!("Folder not found: {}", folder)));
                continue;
            }
            if let Ok(entries) = fs::read_dir(&dir) {
                let mut entry_count = 0u32;
                for entry in entries.flatten() {
                    entry_count += 1;
                    let path = entry.path();
                    info!("SCAN ENTRY #{}: {} is_file={}", entry_count, path.display(), path.is_file());
                    if path.is_file() {
                        if let Some(ext) = path.extension().and_then(|e| e.to_str()) {
                            if matches!(ext.to_lowercase().as_str(), "mp3" | "flac" | "wav" | "m4a")
                            {
                                info!("SCAN FOUND: {}", path.display());
                                all_paths.push(path);
                            }
                        }
                    }
                }
                info!("SCAN DIR TOTAL: {} entries", entry_count);
            } else {
                let _ = sink.add(StreamEvent::Error("Failed to read directory".into()));
            }
        }
        info!("SCAN RESULT: {} music files found", all_paths.len());
        let mut futures: futures::stream::FuturesUnordered<_> = all_paths
            .into_iter()
            .map(|path| {
                process_file(
                    path,
                    &existing,
                    thumbnails_dir.clone(),
                    sink.clone(),
                    min_duration_s,
                )
            })
            .collect();

        let mut results: Vec<(Song, Option<Vec<u8>>)> = Vec::new();

        while let Some(res) = futures.next().await {
            if let Some(val) = res {
                results.push(val);
            }
        }
        if !results.is_empty() {
            let mut collection = locked_song_collection();
            for (song, art) in results {
                if let Err(e) = collection.add_song(song, art) {
                    let _ = sink.add(StreamEvent::Error(e.to_string()));
                }
            }
        }

        let _ = sink.add(StreamEvent::Done);
    });
}

async fn process_file(
    path: PathBuf,
    existing: &HashMap<u64, i64>,
    thumbnails_dir: PathBuf,
    sink: StreamSink<StreamEvent>,
    min_duration_s: u32,
) -> Option<(Song, Option<Vec<u8>>)> {
    let path_string = path.to_string_lossy().to_string();
    let song_id = hash_string(&path_string);
    let last_modified = fs::metadata(&path)
        .and_then(|m| m.modified())
        .ok()
        .and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok())
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0);

    if existing.get(&song_id) == Some(&last_modified) {
        if let Some(cached) = locked_song_collection().get_song(song_id) {
            // Only emit cached song if it meets the duration threshold
            let duration_ok = cached.duration.unwrap_or(0) >= min_duration_s;
            if duration_ok {
                let _ = sink.add(StreamEvent::Song(cached));
            } else {
                // Song is now too short; remove it from collection
                let _ = locked_song_collection().remove_song(song_id);
            }
        }
        return None;
    }

    let path_clone = path.clone();
    let result =
        tokio::task::spawn_blocking(move || Probe::open(&path_clone).and_then(|p| p.read())).await;
    let tagged_file = match result {
        Ok(Ok(t)) => t,
        Ok(Err(e)) => {
            let _ = sink.add(StreamEvent::Error(format!(
                "Skipping file: failed to read tags ({e})"
            )));
            return None;
        }
        Err(_) => {
            let _ = sink.add(StreamEvent::Error("Tag read task panicked".into()));
            return None;
        }
    };

    let primary_tag = match tagged_file.primary_tag() {
        Some(t) => t,
        None => return None,
    };

    let duration = tagged_file.properties().duration().as_secs();

    // Skip songs shorter than threshold
    if duration < min_duration_s as u64 {
        // Also remove from collection if it existed before
        let _ = locked_song_collection().remove_song(song_id);
        return None;
    }

    let artist = primary_tag.artist().unwrap_or_default().to_string();
    let album = primary_tag.album().unwrap_or_default().to_string();
    let album_art: Option<Vec<u8>> = primary_tag.pictures().first().map(|p| p.data().to_vec());
    let album_art_id = album_art.as_ref().map(|_| hash_string(&path_string));

    let song = Song {
        id: song_id,
        path: path_string.clone(),
        title: primary_tag
            .title()
            .unwrap_or_else(|| {
                Cow::Owned(
                    path.file_stem()
                        .unwrap_or_default()
                        .to_string_lossy()
                        .to_string(),
                )
            })
            .to_string(),
        artist,
        album,
        last_modified_at: last_modified,
        duration: Some(duration as u32),
        album_art_id,
    };
    let album_art_path = thumbnails_dir.join(format!("art_{}.jpg", song.id));
    if !album_art_path.exists() {
        if let Some(ref art_bytes) = album_art {
            let _ = std::fs::write(&album_art_path, art_bytes);
        }
    }

    let _ = sink.add(StreamEvent::Song(song.clone()));
    Some((song, album_art))
}
