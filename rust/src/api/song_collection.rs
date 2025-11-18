use std::{collections::HashMap, path::Path};

use crate::api::{
    data::song::{Song, SongCollection},
    error::custom_error::CustomError,
    utils::{
        database_ops::{get_all_songs_from_db, remove_song_from_db, save_song_to_db},
        sort_modes::SortBy,
    },
};
use lofty::{file::TaggedFileExt, read_from_path};

impl SongCollection {
    #[flutter_rust_bridge::frb(sync)]
    pub fn new() -> Result<Self, CustomError> {
        let song_map: HashMap<u64, Song> = get_all_songs_from_db()?
            .into_iter()
            .filter_map(|song| {
                if Path::new(&song.path).exists() {
                    Some((song.id, song))
                } else {
                    if let Err(e) = remove_song_from_db(song.id) {
                        eprintln!("Failed to remove missing song {}: {}", song.id, e);
                    }
                    None
                }
            })
            .collect();
        Ok(Self { song_map })
    }

    pub fn get_song(&self, id: u64) -> Option<Song> {
        self.song_map.get(&id).cloned()
    }

    pub fn get_all_songs(&self) -> Vec<Song> {
        self.song_map.values().cloned().collect()
    }

    pub fn add_song(&mut self, song: Song) -> Result<(), CustomError> {
        save_song_to_db(song.clone())?;
        self.song_map.insert(song.id, song);
        Ok(())
    }
    pub fn extract_album_art_from_file(path: &str) -> Result<Vec<u8>, CustomError> {
        let tagged_file = read_from_path(path).map_err(|_| CustomError::AlbumArtError)?;
        for tag in tagged_file.tags() {
            if let Some(picture) = tag.pictures().first() {
                return Ok(picture.data().to_vec());
            }
        }
        Err(CustomError::AlbumArtError)
    }
    pub fn remove_song(&mut self, id: u64) -> Result<(), CustomError> {
        remove_song_from_db(id)?;
        self.song_map.remove(&id);
        Ok(())
    }
    ///! also add to playlist collection
    pub fn get_all_sorted(&self, sort_by: SortBy) -> Vec<Song> {
        let mut list: Vec<Song> = self.song_map.values().cloned().collect();
        match sort_by {
            SortBy::NameAscending => list.sort_by(|a, b| a.title.cmp(&b.title)),
            SortBy::NameDescending => list.sort_by(|a, b| b.title.cmp(&a.title)),
            SortBy::DurationAscending => list.sort_by(|a, b| a.duration.cmp(&b.duration)),
            SortBy::DurationDescending => list.sort_by(|a, b| b.duration.cmp(&a.duration)),
            SortBy::DateModifiedAscending => {
                list.sort_by(|a, b| a.last_modified_at.cmp(&b.last_modified_at))
            }
            SortBy::DateModifiedDescending => {
                list.sort_by(|a, b| b.last_modified_at.cmp(&a.last_modified_at))
            }
        }
        list
    }
}
