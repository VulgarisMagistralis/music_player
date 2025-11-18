use crate::api::data::song::Song;
use crate::api::data::song::SongCollection;
use crate::api::error::custom_error::CustomError;
use crate::api::music_folder::get_music_folder_list;
use crate::api::utils::hash::hash_string;
use lofty::file::TaggedFileExt;
use lofty::probe::Probe;
use lofty::tag::Accessor;
use std::borrow::Cow;
use std::fs;
use std::path::Path;
use std::path::PathBuf;

#[flutter_rust_bridge::frb()]
pub fn read_music_files() -> Result<Vec<Song>, CustomError> {
    let folders = get_music_folder_list()?;
    if folders.is_empty() {
        return Ok(Vec::new());
    }
    let mut song_list: Vec<Song> = Vec::new();
    let mut song_collection = SongCollection::new()?;

    for folder in folders {
        let dir = PathBuf::from(&folder);
        if !dir.exists() || !dir.is_dir() {
            continue;
        }

        for entry in fs::read_dir(&dir)
            .map_err(|_| CustomError::InvalidPath("Failed to read dir {folder}: {e}".into()))?
        {
            let entry = match entry {
                Ok(e) => e,
                Err(_) => continue,
            };

            let path = entry.path();
            let path_file = Path::new(&path);
            assert!(path_file.is_file(), "ERROR: Path is not a file!");

            let Some(ext) = path_file.extension().and_then(|e| e.to_str()) else {
                continue;
            };
            if !matches!(ext.to_lowercase().as_str(), "mp3" | "flac" | "wav" | "m4a") {
                continue;
            }

            let tagged_file = match Probe::open(path_file).and_then(|p| p.read()) {
                Ok(t) => t,
                Err(e) => {
                    eprintln!("Skipping file {:?}: failed to read tags ({e})", path_file);
                    continue;
                }
            };
            match tagged_file.primary_tag() {
                Some(primary_tag) => {
                    let path_string = path_file.to_string_lossy().to_string();
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
                            .map_err(|_| {
                                CustomError::Unknown("Last modified date not given".to_string())
                            })?
                            .modified()
                            .map(|t| {
                                t.duration_since(std::time::UNIX_EPOCH)
                                    .unwrap_or_default()
                                    .as_secs() as i64
                            })
                            .unwrap_or(0),
                        duration: None,
                    };
                    song_list.push(song.clone());
                    song_collection.add_song(song)?;
                }
                None => {}
            };
        }
    }
    Ok(song_list)
}
