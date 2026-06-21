use bincode::{Decode, Encode};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[flutter_rust_bridge::frb()]
#[derive(Serialize, Deserialize, Encode, Decode, Clone, Debug, PartialEq)]
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

#[cfg(test)]
mod tests {
    use super::*;
    use bincode::config::standard;
    use bincode::{decode_from_slice, encode_to_vec};

    fn make_song(id: u64, title: &str) -> Song {
        Song {
            id,
            path: "/music/track.mp3".into(),
            title: title.to_string(),
            artist: "Artist".into(),
            album: "Album".into(),
            last_modified_at: 1000,
            duration: Some(240),
            album_art_id: None,
        }
    }

    #[test]
    fn song_serialization_roundtrip() {
        let song = make_song(1, "My Song");
        let bytes = encode_to_vec(&song, standard()).unwrap();
        let (decoded, _) = decode_from_slice::<Song, _>(&bytes, standard()).unwrap();
        assert_eq!(song, decoded);
    }

    #[test]
    fn song_partial_fields() {
        let song = Song {
            id: 42,
            path: "/music/track.flac".into(),
            title: "Incomplete".into(),
            artist: String::new(),
            album: String::new(),
            last_modified_at: 0,
            duration: None,
            album_art_id: None,
        };
        let bytes = encode_to_vec(&song, standard()).unwrap();
        let (decoded, _) = decode_from_slice::<Song, _>(&bytes, standard()).unwrap();
        assert_eq!(song, decoded);
    }

    #[test]
    fn song_equality() {
        let a = make_song(1, "Track");
        let b = make_song(1, "Track");
        let c = make_song(2, "Track");
        assert_eq!(a, b);
        assert_ne!(a, c);
    }

    #[test]
    fn song_clone_preserves_fields() {
        let s = make_song(7, "Cloned");
        let c = s.clone();
        assert_eq!(s, c);
        assert_eq!(s.album_art_id, c.album_art_id);
    }
}
