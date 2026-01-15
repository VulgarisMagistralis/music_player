use crate::api::data::playlist::{Playlist, PlaylistCollection};
use crate::api::error::custom_error::CustomError;
use crate::api::utils::database_ops::{
    delete_playlist_from_db, get_all_playlists_from_db, next_playlist_id,
    remove_playlist_entry_from_db, save_playlist_entry_to_db, save_playlist_to_db,
    update_playlist_name_in_db,
};
use log::error;
use std::collections::HashMap;
use std::sync::{Mutex, MutexGuard, OnceLock};
static PLAYLIST_COLLECTION: OnceLock<Mutex<PlaylistCollection>> = OnceLock::new();

pub(crate) fn locked_playlist_collection() -> MutexGuard<'static, PlaylistCollection> {
    match PLAYLIST_COLLECTION
        .get_or_init(|| Mutex::new(PlaylistCollection::new().expect("playlist init")))
        .lock()
    {
        Ok(g) => g,
        Err(poisoned) => {
            error!("PLAYLIST_COLLECTION poisoned, recovering...");
            poisoned.into_inner()
        }
    }
}

#[flutter_rust_bridge::frb]
pub fn add_playlist_to_collection(name: String) -> Result<Playlist, CustomError> {
    let mut playlist_collection = locked_playlist_collection();
    let id = next_playlist_id()?;
    let playlist = Playlist {
        id,
        name: name,
        song_id_list: vec![],
    };
    playlist_collection.add_playlist(playlist)
}

#[flutter_rust_bridge::frb]
pub fn get_all_playlists_from_collection() -> Vec<Playlist> {
    let playlist_collection = locked_playlist_collection();
    playlist_collection.get_all_playlists()
}

#[flutter_rust_bridge::frb]
pub fn remove_song_from_playlist(song_id: u64, playlist_id: u64) -> Result<(), CustomError> {
    let mut playlist_collection = locked_playlist_collection();
    playlist_collection.remove_song(playlist_id, song_id)
}

#[flutter_rust_bridge::frb]
pub fn add_song_to_playlist(song_id: u64, playlist_id: u64) -> Result<(), CustomError> {
    let mut playlist_collection = locked_playlist_collection();
    playlist_collection.add_song(playlist_id, song_id)
}

#[flutter_rust_bridge::frb]
pub fn delete_playlist(playlist_id: u64) -> Result<(), CustomError> {
    let mut playlist_collection = locked_playlist_collection();
    playlist_collection.delete_playlist(playlist_id)
}

#[flutter_rust_bridge::frb]
pub fn rename_playlist(playlist_id: u64, new_name: &str) -> Result<(), CustomError> {
    let mut playlist_collection = locked_playlist_collection();
    playlist_collection.rename_playlist(playlist_id, new_name)
}

#[flutter_rust_bridge::frb]
pub fn is_in_favourites(song_id: u64) -> bool {
    let playlist_collection = locked_playlist_collection();
    playlist_collection.is_favourite(song_id)
}

#[flutter_rust_bridge::frb]
pub fn add_song_to_favourites(song_id: u64) -> Result<(), CustomError> {
    let mut playlist_collection = locked_playlist_collection();
    playlist_collection.add_to_favourites(song_id)
}

#[flutter_rust_bridge::frb]
pub fn remove_song_from_favourites(song_id: u64) -> Result<(), CustomError> {
    let mut playlist_collection = locked_playlist_collection();
    playlist_collection.remove_from_favourites(song_id)
}

#[flutter_rust_bridge::frb]
pub fn get_favourites_from_collection() -> Playlist {
    let playlist_collection = locked_playlist_collection();
    playlist_collection.favourites()
}

/// DB ops go through implementation and
/// has a hashmap for fast responses
impl PlaylistCollection {
    pub fn new() -> Result<Self, CustomError> {
        let mut playlists = get_all_playlists_from_db().map_err(|_| {
            CustomError::PlaylistCollectionError("Failed to fetch playlists".into())
        })?;

        let favourites_playlist_id =
            if let Some(p) = playlists.iter().find(|p| p.name == "favourites") {
                p.id
            } else {
                let id = next_playlist_id()?;
                let favourites = Playlist {
                    id,
                    name: "favourites".into(),
                    song_id_list: vec![],
                };
                save_playlist_to_db(favourites.clone())?;
                playlists.push(favourites);
                id
            };

        let playlist_map: HashMap<u64, Playlist> =
            playlists.into_iter().map(|p| (p.id, p)).collect();

        let favourites_cache = playlist_map
            .get(&favourites_playlist_id)
            .map(|p| p.song_id_list.iter().copied().collect())
            .unwrap_or_default();

        Ok(Self {
            playlist_map,
            favourites_cache,
            favourites_playlist_id,
        })
    }

    pub fn is_favourite(&self, song_id: u64) -> bool {
        self.favourites_cache.contains(&song_id)
    }

    pub fn favourites(&self) -> Playlist {
        self.playlist_map[&self.favourites_playlist_id].clone()
    }

    pub fn add_to_favourites(&mut self, song_id: u64) -> Result<(), CustomError> {
        if self.favourites_cache.contains(&song_id) {
            return Ok(());
        }

        let playlist = self
            .playlist_map
            .get_mut(&self.favourites_playlist_id)
            .ok_or_else(|| {
                CustomError::PlaylistCollectionError("Favourites playlist missing".into())
            })?;

        if let Err(e) = save_playlist_entry_to_db(playlist.id, song_id) {
            playlist.song_id_list.retain(|&id| id != song_id);
            return Err(e);
        }

        playlist.song_id_list.push(song_id);
        self.favourites_cache.insert(song_id);

        Ok(())
    }

    pub fn remove_from_favourites(&mut self, song_id: u64) -> Result<(), CustomError> {
        if !self.favourites_cache.contains(&song_id) {
            return Ok(());
        }

        let playlist = self
            .playlist_map
            .get_mut(&self.favourites_playlist_id)
            .ok_or_else(|| {
                CustomError::PlaylistCollectionError("Favourites playlist missing".into())
            })?;

        remove_playlist_entry_from_db(playlist.id, song_id)?;
        playlist.song_id_list.retain(|&id| id != song_id);
        self.favourites_cache.remove(&song_id);

        Ok(())
    }

    pub fn get_all_playlists(&self) -> Vec<Playlist> {
        let mut playlists: Vec<_> = self
            .playlist_map
            .values()
            .filter(|p| p.id != self.favourites_playlist_id)
            .cloned()
            .collect();
        playlists.sort_by_key(|playlist| playlist.id);
        playlists
    }

    pub fn get_playlist(&self, playlist_id: u64) -> Result<Playlist, CustomError> {
        self.playlist_map
            .get(&playlist_id)
            .cloned()
            .ok_or(CustomError::PlaylistNotFound)
    }

    pub fn add_playlist(&mut self, playlist: Playlist) -> Result<Playlist, CustomError> {
        save_playlist_to_db(playlist.clone())?;
        self.playlist_map.insert(playlist.id, playlist.clone());
        Ok(playlist)
    }

    pub fn add_song(&mut self, playlist_id: u64, song_id: u64) -> Result<(), CustomError> {
        let playlist = self
            .playlist_map
            .get_mut(&playlist_id)
            .ok_or(CustomError::PlaylistNotFound)?;

        if !playlist.song_id_list.contains(&song_id) {
            playlist.song_id_list.push(song_id);
            if let Err(e) = save_playlist_entry_to_db(playlist_id, song_id) {
                playlist.song_id_list.retain(|&id| id != song_id);
                return Err(e);
            }
        }
        Ok(())
    }

    pub fn remove_song(&mut self, playlist_id: u64, song_id: u64) -> Result<(), CustomError> {
        let playlist = self
            .playlist_map
            .get_mut(&playlist_id)
            .ok_or(CustomError::PlaylistNotFound)?;

        playlist.song_id_list.retain(|&id| id != song_id);
        remove_playlist_entry_from_db(playlist_id, song_id)?;
        Ok(())
    }

    pub fn rename_playlist(&mut self, playlist_id: u64, new_name: &str) -> Result<(), CustomError> {
        let playlist = self
            .playlist_map
            .get_mut(&playlist_id)
            .ok_or(CustomError::PlaylistNotFound)?;

        playlist.name = new_name.to_string();
        update_playlist_name_in_db(playlist_id, new_name)?;
        Ok(())
    }

    pub fn delete_playlist(&mut self, playlist_id: u64) -> Result<(), CustomError> {
        self.playlist_map
            .remove(&playlist_id)
            .ok_or(CustomError::PlaylistNotFound)?;

        delete_playlist_from_db(playlist_id)?;
        Ok(())
    }
}
