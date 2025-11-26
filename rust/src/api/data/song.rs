use bincode::{Decode, Encode};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[flutter_rust_bridge::frb()]
#[derive(Serialize, Deserialize, Encode, Decode, Clone, Debug)]
pub struct Song {
    pub id: u64,
    pub path: String,
    pub title: String,
    pub artist: String,
    pub album: String,
    pub last_modified_at: i64,
    pub duration: Option<u32>,
    pub album_art_id: Option<u64>,
}
#[flutter_rust_bridge::frb(opaque)]
#[derive(Serialize, Deserialize, Encode, Decode, Clone, Debug)]
pub struct SongCollection {
    pub song_map: HashMap<u64, Song>,
    pub(crate) art_map: HashMap<u64, Vec<u8>>,
}
