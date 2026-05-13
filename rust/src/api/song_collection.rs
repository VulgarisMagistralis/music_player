use crate::api::data::song::{Song, SongCollection};
use crate::api::error::custom_error::CustomError;
use crate::api::utils::database_ops::remove_all_songs_from_db;
use crate::api::utils::database_ops::remove_song_from_db;
use crate::api::utils::database_ops::save_song_art_to_db;
use crate::api::utils::database_ops::save_song_to_db;
use crate::api::utils::database_ops::{get_all_songs_from_db, get_song_art_from_db};
use crate::api::utils::sort_modes::SortBy;
use lofty::{file::TaggedFileExt, read_from_path};
use log::{error, info};
use std::sync::{Mutex, OnceLock};
use std::{collections::HashMap, path::Path};
static SONG_COLLECTION: OnceLock<Mutex<SongCollection>> = OnceLock::new();

#[flutter_rust_bridge::frb(sync)]
pub(crate) fn locked_song_collection() -> std::sync::MutexGuard<'static, SongCollection> {
    match SONG_COLLECTION
        .get_or_init(|| Mutex::new(SongCollection::new().expect("Failed to load SongCollection")))
        .lock()
    {
        Ok(g) => g,
        Err(poisoned) => {
            error!("SONG_COLLECTION poisoned, recovering...");
            poisoned.into_inner()
        }
    }
}

#[flutter_rust_bridge::frb]
pub fn add_song_to_collection(song: Song, art: Option<Vec<u8>>) -> Result<(), String> {
    let mut song_collection = locked_song_collection();
    song_collection
        .add_song(song, art)
        .map_err(|e| e.to_string())
}

#[flutter_rust_bridge::frb]
pub fn get_all_songs_from_collection() -> Vec<Song> {
    let song_collection = locked_song_collection();
    song_collection.get_all_songs()
}

#[flutter_rust_bridge::frb]
pub fn get_sorted_songs(sort: SortBy) -> Vec<Song> {
    let song_collection = locked_song_collection();
    song_collection.get_all_sorted(sort)
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_song_album_art_file_path(id: u64) -> String {
    let song_collection = locked_song_collection();
    song_collection.get_album_art_file_path(id)
}

#[flutter_rust_bridge::frb]
pub fn get_song_album_art(id: u64) -> Option<Vec<u8>> {
    // needs mut for lazy DB load on cache miss
    let mut song_collection = locked_song_collection();
    song_collection.get_album_art(id)
}

#[flutter_rust_bridge::frb]
pub fn get_song(id: u64) -> Option<Song> {
    let song_collection = locked_song_collection();
    song_collection.get_song(id)
}

#[flutter_rust_bridge::frb]
pub fn get_song_list(id_list: Vec<u64>) -> Vec<Song> {
    let song_collection = locked_song_collection();
    id_list
        .into_iter()
        .filter_map(|song_id| song_collection.get_song(song_id))
        .collect()
}

impl SongCollection {
    pub fn new() -> Result<Self, CustomError> {
        // CHANGE: art_map starts empty — art is loaded lazily on first request.
        // Previously new() called get_song_art_from_db() for every song at
        // startup: O(n) DB reads before the app shows anything. Now startup
        // is a single get_all_songs_from_db() call, and art is fetched from
        // DB on demand and cached. AA still gets art — just on first request
        // per song rather than all at once at boot.
        let song_map: HashMap<u64, Song> = get_all_songs_from_db()?
            .into_iter()
            .filter(|song| Path::new(&song.path).exists())
            .map(|song| (song.id, song))
            .collect();

        Ok(Self {
            song_map,
            art_map: HashMap::new(), // populated lazily in get_album_art()
        })
    }

    pub fn get_song(&self, id: u64) -> Option<Song> {
        self.song_map.get(&id).cloned()
    }

    /// CHANGE: &mut self for lazy DB load on cache miss.
    /// Art is fetched from DB once and cached in art_map on first request.
    /// Subsequent calls for the same id return from cache. AA behaviour
    /// is identical — it just pays one DB read the first time instead of
    /// loading everything into RAM at startup.
    pub fn get_album_art(&mut self, song_id: u64) -> Option<Vec<u8>> {
        if self.art_map.contains_key(&song_id) {
            return self.art_map.get(&song_id).cloned();
        }
        // Cache miss — load from DB and cache for next time
        if let Ok(Some(bytes)) = get_song_art_from_db(song_id) {
            self.art_map.insert(song_id, bytes.clone());
            return Some(bytes);
        }
        None
    }

    pub fn get_album_art_file_path(&self, song_id: u64) -> String {
        format!("thumbnails/art_{}.jpg", song_id)
    }

    pub fn get_all_songs(&self) -> Vec<Song> {
        let mut song_list: Vec<Song> = self.song_map.values().cloned().collect();
        song_list.sort_by_key(|song| song.id);
        song_list
    }

    pub fn add_song(&mut self, song: Song, album_art: Option<Vec<u8>>) -> Result<(), CustomError> {
        save_song_to_db(&song)?;
        if let (Some(album_art_id), Some(bytes)) = (song.album_art_id, album_art) {
            save_song_art_to_db(album_art_id, bytes.clone())?;
            self.art_map.insert(album_art_id, bytes);
        } else {
            info!("No album art for song id {}", song.id);
        }
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
        self.art_map.remove(&id); // CHANGE: was missing, causing memory leak
        Ok(())
    }

    pub fn remove_all_songs(&mut self) -> Result<(), CustomError> {
        remove_all_songs_from_db()?;
        self.song_map.clear();
        self.art_map.clear(); // BUG FIX: was missing in original
        Ok(())
    }

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
