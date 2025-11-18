use crate::api::data::{playlist::Playlist, song::Song};
use crate::api::error::custom_error::CustomError;
use crate::api::utils::hash::hash_string;
use bincode::config::{standard, Configuration};
use bincode::{decode_from_slice, encode_to_vec};
use sled::{Db, IVec, Tree};
use std::{path::PathBuf, sync::OnceLock};

static DB_INSTANCE_DIR: OnceLock<PathBuf> = OnceLock::new();
static DB_INSTANCE: OnceLock<Db> = OnceLock::new();
const SONG_TREE: &str = "song";
const PLAYLIST_TREE: &str = "playlist";
const SETTINGS_TREE: &str = "settings";
const FOLDER_PREFIX: &str = "folder";
const ENCODING_CONFIGURATION: Configuration = standard();
/// todo
/// store last playlist/song

/// Playlist key in DB: playlist::<u64>
fn song_key(id: u64) -> String {
    format!("{SONG_TREE}::{id}")
}

fn playlist_key(id: u64) -> String {
    format!("{PLAYLIST_TREE}::{id}")
}

fn folder_key(id: u64) -> String {
    format!("{FOLDER_PREFIX}::{id}")
}

pub fn set_db_dir(db_dir: String) -> Result<(), String> {
    let db_path = PathBuf::from(&db_dir);
    let _ = DB_INSTANCE_DIR.set(db_path.clone());
    let db = sled::open(db_path).map_err(|e| format!("Failed to open sled DB: {}", e))?;
    let _ = DB_INSTANCE.set(db);
    Ok(())
}

pub(crate) fn open_or_fetch_tree(new_tree_name: String) -> Result<Tree, String> {
    let db = DB_INSTANCE
        .get()
        .ok_or_else(|| "DB not initialized".to_string())?;

    db.open_tree(&new_tree_name)
        .map_err(|e| format!("Failed to open tree '{}': {}", new_tree_name, e))
}

pub(crate) fn get_song_tree() -> Result<Tree, String> {
    open_or_fetch_tree(SONG_TREE.to_string())
}

pub(crate) fn get_playlist_tree() -> Result<Tree, String> {
    open_or_fetch_tree(PLAYLIST_TREE.to_string())
}

pub(crate) fn get_settings_tree() -> Result<Tree, String> {
    open_or_fetch_tree(SETTINGS_TREE.to_string())
}

pub(crate) fn save_song_to_db(song: Song) -> Result<(), CustomError> {
    get_song_tree()
        .map_err(|e| CustomError::TreeError(e.to_string()))?
        .insert(
            song_key(song.id),
            encode_to_vec(&song, ENCODING_CONFIGURATION).map_err(|_| CustomError::EncodeError)?,
        )
        .map_err(|e| CustomError::DbError(e.to_string()))?;
    Ok(())
}

pub(crate) fn save_playlist_to_db(playlist: Playlist) -> Result<Option<IVec>, CustomError> {
    Ok(get_playlist_tree()
        .map_err(|e| CustomError::TreeError(e.to_string()))?
        .insert(
            playlist_key(playlist.id),
            encode_to_vec(&playlist, ENCODING_CONFIGURATION)
                .map_err(|_| CustomError::EncodeError)?,
        )
        .map_err(|e| CustomError::DbError(e.to_string()))?)
}

pub(crate) fn get_playlist_from_db(playlist_id: u64) -> Result<Playlist, CustomError> {
    let encoded_playlist = get_playlist_tree()
        .map_err(|e| CustomError::TreeError(e.to_string()))?
        .get(playlist_key(playlist_id))
        .map_err(|e| CustomError::DbError(e.to_string()))? // DB error
        .ok_or(CustomError::DbError("Not found".to_string()))?;

    let (playlist, _): (Playlist, usize) =
        decode_from_slice(&encoded_playlist, ENCODING_CONFIGURATION)
            .map_err(|_| CustomError::DecodeError)?;
    return Ok(playlist);
}

pub(crate) fn get_all_playlists_from_db() -> Result<Vec<Playlist>, CustomError> {
    let mut playlists = Vec::new();
    for result in get_playlist_tree()
        .map_err(|e| CustomError::TreeError(e.to_string()))?
        .iter()
    {
        let (_, value) = result.map_err(|e| CustomError::DbError(e.to_string()))?;
        let (playlist, _): (Playlist, usize) = decode_from_slice(&value, ENCODING_CONFIGURATION)
            .map_err(|_| CustomError::DecodeError)?;
        playlists.push(playlist);
    }
    Ok(playlists)
}

pub(crate) fn get_all_songs_from_db() -> Result<Vec<Song>, CustomError> {
    let mut song_list = Vec::new();
    for result in get_song_tree()
        .map_err(|e| CustomError::TreeError(e.to_string()))?
        .iter()
    {
        let (_, value) = result.map_err(|e| CustomError::DbError(e.to_string()))?;
        let (song, _): (Song, usize) = decode_from_slice(&value, ENCODING_CONFIGURATION)
            .map_err(|_| CustomError::DecodeError)?;
        song_list.push(song);
    }
    Ok(song_list)
}

pub(crate) fn save_music_folder_to_db(folder_path: &String) -> Result<Option<IVec>, CustomError> {
    let res = get_settings_tree()
        .map_err(|e| CustomError::TreeError(e.to_string()))?
        .insert(folder_key(hash_string(folder_path)), folder_path.as_bytes())
        .map_err(|e| CustomError::DbError(e.to_string()))?;
    Ok(res)
}

pub(crate) fn get_music_folders_from_db() -> Result<Vec<String>, CustomError> {
    let mut folder_list = Vec::new();
    for item in get_settings_tree()
        .map_err(|e| CustomError::TreeError(e.to_string()))?
        .scan_prefix(FOLDER_PREFIX)
    {
        let (_, value) = item.map_err(|e| CustomError::DbError(e.to_string()))?;
        folder_list.push(String::from_utf8(value.to_vec()).map_err(|_| CustomError::Utf8Error)?);
    }
    Ok(folder_list)
}

pub(crate) fn remove_music_folder_from_db(folder_path: &str) -> Result<(), CustomError> {
    let settings_tree = get_settings_tree().map_err(|e| CustomError::TreeError(e.to_string()))?;
    for item in settings_tree.scan_prefix(FOLDER_PREFIX) {
        let (_, value) = item.map_err(|e| CustomError::DbError(e.to_string()))?;
        let (folder_path_in_db, _): (String, usize) =
            decode_from_slice(&value, ENCODING_CONFIGURATION)
                .map_err(|_| CustomError::DecodeError)?;
        if folder_path_in_db == folder_path {
            let _ = settings_tree.remove(folder_key(hash_string(folder_path)));
        }
    }
    Ok(())
}

pub(crate) fn remove_song_from_db(id: u64) -> Result<(), CustomError> {
    let song_tree = get_song_tree().map_err(|e| CustomError::TreeError(e.to_string()))?;
    let _ = song_tree.remove(song_key(id));
    Ok(())
}
