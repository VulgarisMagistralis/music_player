use bincode::{Decode, Encode};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
///todo add last sort by
#[derive(Serialize, Deserialize, Encode, Decode, Clone, Debug)]
#[flutter_rust_bridge::frb(opaque)]
pub struct Playlist {
    pub id: u64,
    pub name: String,
    pub song_id_list: Vec<u64>,
}

#[derive(Serialize, Deserialize, Encode, Decode, Clone, Debug)]
#[flutter_rust_bridge::frb(opaque)]
pub struct PlaylistCollection {
    pub playlist_map: HashMap<u64, Playlist>,
}
