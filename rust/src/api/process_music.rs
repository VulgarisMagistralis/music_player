use crate::api::data::song::Song;
use crate::api::data::stream_event::StreamEvent;
use crate::api::music_folder::get_music_folder_list;
use crate::api::music_folder::get_thumbnails_dir;
use crate::api::song_collection::locked_song_collection;
use crate::api::utils::hash::hash_string;
use crate::frb_generated::StreamSink;
use lofty::file::AudioFile;
use lofty::file::TaggedFileExt;
use lofty::probe::Probe;
use lofty::tag::Accessor;
use std::borrow::Cow;
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use tokio::task::spawn;

#[flutter_rust_bridge::frb()]
pub async fn read_music_files(sink: StreamSink<StreamEvent>) {
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
            if !dir.exists() || !dir.is_dir() {
                continue;
            }
            let entries = match fs::read_dir(&dir) {
                Ok(e) => e,
                Err(_) => {
                    let _ = sink.add(StreamEvent::Error("Failed to read directory".into()));
                    continue;
                }
            };
            for entry in entries.flatten() {
                let path = entry.path();
                if !path.is_file() {
                    continue;
                }
                let ext = path
                    .extension()
                    .and_then(|e| e.to_str())
                    .map(|e| e.to_lowercase())
                    .unwrap_or_default();
                if matches!(ext.as_str(), "mp3" | "flac" | "wav" | "m4a") {
                    all_paths.push(path);
                }
            }
        }

        let mut songs_to_add: Vec<(Song, Option<Vec<u8>>)> = Vec::new();

        for path in all_paths {
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
                    let _ = sink.add(StreamEvent::Song(cached));
                }
                continue;
            }

            let path_for_probe = path.clone();
            let tagged_file = match tokio::task::spawn_blocking(move || {
                Probe::open(&path_for_probe).and_then(|p| p.read())
            })
            .await
            {
                Ok(Ok(t)) => t,
                Ok(Err(e)) => {
                    let _ = sink.add(StreamEvent::Error(format!(
                        "Skipping file: failed to read tags ({e})"
                    )));
                    continue;
                }
                Err(_) => {
                    let _ = sink.add(StreamEvent::Error("Tag read task panicked".into()));
                    continue;
                }
            };

            let Some(primary_tag) = tagged_file.primary_tag() else {
                continue;
            };

            let duration = tagged_file.properties().duration().as_secs();
            let artist = primary_tag.artist().unwrap_or_default().to_string();
            let album = primary_tag.album().unwrap_or_default().to_string();
            let album_art: Option<Vec<u8>> =
                primary_tag.pictures().first().map(|p| p.data().to_vec());
            let album_art_id = album_art.as_ref().map(|_| hash_string(&path_string));

            let song = Song {
                id: song_id,
                path: path_string,
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
                    if let Err(e) = std::fs::write(&album_art_path, art_bytes) {
                        eprintln!("Failed to write artwork for song {}: {}", song.id, e);
                    }
                }
            }

            let _ = sink.add(StreamEvent::Song(song.clone()));
            songs_to_add.push((song, album_art));
        }
        if !songs_to_add.is_empty() {
            let mut collection = locked_song_collection();
            for (song, art) in songs_to_add {
                if let Err(e) = collection.add_song(song, art) {
                    let _ = sink.add(StreamEvent::Error(e.to_string()));
                }
            }
        }

        let _ = sink.add(StreamEvent::Done);
    });
}
