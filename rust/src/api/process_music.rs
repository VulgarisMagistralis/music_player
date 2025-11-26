use crate::api::data::song::Song;
use crate::api::data::stream_event::StreamEvent;
use crate::api::music_folder::get_music_folder_list;
use crate::api::song_collection::locked_song_collection;
use crate::api::utils::hash::hash_string;
use crate::frb_generated::StreamSink;
use lofty::file::TaggedFileExt;
use lofty::probe::Probe;
use lofty::tag::Accessor;
use std::borrow::Cow;
use std::fs;
use std::path::Path;
use std::path::PathBuf;
use tokio::task::spawn;

#[flutter_rust_bridge::frb()]
pub async fn read_music_files(sink: StreamSink<StreamEvent>) {
    spawn(async move {
        let folders = match get_music_folder_list() {
            Ok(f) => f,
            Err(_) => {
                let _ = sink.add(StreamEvent::Error("Failed to fetch folder".into()));
                return;
            }
        };
        let mut locked_collection = locked_song_collection();
        if folders.is_empty() {
            let _ = locked_collection.remove_all_songs();
            let _ = sink.add(StreamEvent::Done);
            return;
        }

        for folder in folders {
            let dir = PathBuf::from(&folder);
            if !dir.exists() || !dir.is_dir() {
                continue;
            }
            let entries = match fs::read_dir(&dir) {
                Ok(e) => e,
                Err(_) => {
                    let _ = sink.add(StreamEvent::Error("Failed to read file".into()));
                    continue;
                }
            };
            for entry in entries {
                let entry = match entry {
                    Ok(e) => e,
                    Err(_) => {
                        let _ = sink.add(StreamEvent::Error("Corrupted entry".into()));
                        continue;
                    }
                };
                let path = entry.path();
                let path_file = Path::new(&path);
                if !path_file.is_file() {
                    continue;
                }
                let ext = match path_file.extension().and_then(|e| e.to_str()) {
                    Some(e) => e.to_lowercase(),
                    None => {
                        let _ = sink.add(StreamEvent::Error("File missing extension".into()));
                        continue;
                    }
                };
                if !matches!(ext.to_lowercase().as_str(), "mp3" | "flac" | "wav" | "m4a") {
                    let _ = sink.add(StreamEvent::Error(format!("Unsupported file type {}", ext)));
                    continue;
                }

                let tagged_file = match Probe::open(path_file).and_then(|p| p.read()) {
                    Ok(t) => t,
                    Err(e) => {
                        let _ = sink.add(StreamEvent::Error(format!(
                            "Skipping file : failed to read tags ({e})",
                        )));
                        continue;
                    }
                };
                if let Some(primary_tag) = tagged_file.primary_tag() {
                    let path_string = path_file.to_string_lossy().to_string();
                    let album_art: Option<Vec<u8>> =
                        primary_tag.pictures().first().map(|p| p.data().to_vec());
                    let album_art_id = album_art.as_ref().map(|_| hash_string(&path_string));
                    let song = Song {
                        id: hash_string(&path_string),
                        path: path_string,
                        title: primary_tag
                            .title()
                            .unwrap_or_else(|| {
                                Cow::Owned(
                                    path_file
                                        .file_stem()
                                        .unwrap_or_default()
                                        .to_string_lossy()
                                        .to_string(),
                                )
                            })
                            .to_string(),
                        artist: "".into(),
                        album: "".into(),
                        last_modified_at: fs::metadata(path_file)
                            .and_then(|m| m.modified())
                            .ok()
                            .and_then(|t| {
                                t.duration_since(std::time::UNIX_EPOCH)
                                    .ok()
                                    .map(|d| d.as_secs() as i64)
                            })
                            .unwrap_or(0),
                        duration: None,
                        album_art_id,
                    };
                    if let Err(e) = locked_collection.add_song(song.clone(), album_art.clone()) {
                        let _ = sink.add(StreamEvent::Error(e.to_string()));
                        continue;
                    }
                    let _ = sink.add(StreamEvent::Song(song));
                };
            }
        }

        let _ = sink.add(StreamEvent::Done);
    });
}
