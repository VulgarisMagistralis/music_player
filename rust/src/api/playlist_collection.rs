use crate::api::data::playlist::{Playlist, PlaylistCollection};
use crate::api::data::song::Song;
use crate::api::error::custom_error::CustomError;
use crate::api::utils::database_ops::{
    get_all_playlists_from_db, get_all_songs_from_db, get_playlist_from_db, save_playlist_to_db,
};
use crate::api::utils::hash::hash_string;
use std::collections::HashMap;
///!remove
const DEFAULT_PLAYLIST_NAME: &str = "All Songs";
/// SongCollection struct
/// PlaylistCollection struct
/// PlayerState struct

/// DB ops go through implementation and
/// has a hashmap for fast responses
impl PlaylistCollection {
    #[flutter_rust_bridge::frb(sync)]
    pub fn new() -> Result<Self, CustomError> {
        let playlists = get_all_playlists_from_db().map_err(|_| {
            CustomError::PlaylistCollectionError("Failed to fetch playlists".into())
        })?;
        let playlist_map: HashMap<u64, Playlist> =
            playlists.into_iter().map(|p| (p.id, p)).collect();
        Ok(Self {
            playlist_map,
            default_playlist_id: hash_string(DEFAULT_PLAYLIST_NAME),
        })
    }

    pub fn get_all_playlists(&self) -> Vec<Playlist> {
        self.playlist_map.values().cloned().collect()
    }

    pub fn get_playlist(&self, playlist_id: u64) -> Result<Playlist, CustomError> {
        get_playlist_from_db(playlist_id)
    }

    pub fn get_default_playlist(&self) -> Result<Vec<Song>, CustomError> {
        get_all_songs_from_db()
    }

    pub fn add_playlist(&mut self, name: &str) -> Result<Playlist, CustomError> {
        let id: u64 = hash_string(name);
        let playlist = Playlist {
            id,
            name: name.to_string(),
            songs: vec![],
        };
        save_playlist_to_db(playlist.clone())?;
        self.playlist_map.insert(id, playlist.clone());
        Ok(playlist)
    }

    // Add a song to a playlist (duplicates ignored)
    // pub fn add_song_to_playlist(&mut self, playlist_id: u64, song_id: u64) -> Result<(), String> {
    //     match self.playlist_map.get_mut(&playlist_id) {
    //         Some(pl) => {
    //             if !pl.songs.contains(&song_id) {
    //                 pl.songs.push(song_id);
    //             }
    //             Ok(())
    //         }
    //         None => Err("Playlist not found".into()),
    //     }
    // }

    // pub fn remove_song_from_playlist(
    //     &mut self,
    //     playlist_id: u64,
    //     song_id: u64,
    // ) -> Result<(), String> {
    //     match self.playlist_map.get_mut(&playlist_id) {
    //         Some(pl) => {
    //             pl.songs.retain(|&id| id != song_id);
    //             Ok(())
    //         }
    //         None => Err("Playlist not found".into()),
    //     }
    // }
}
