use bincode::{Decode, Encode};
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};

///todo add last sort by
#[derive(Serialize, Deserialize, Encode, Decode, Clone, Debug, PartialEq)]
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
    pub favourites_playlist_id: u64,
    pub favourites_cache: HashSet<u64>,
}

#[cfg(test)]
mod tests {
    use super::*;
    use bincode::config::standard;
    use bincode::{decode_from_slice, encode_to_vec};

    fn make_playlist(id: u64) -> Playlist {
        Playlist {
            id,
            name: "My Playlist".into(),
            song_id_list: vec![1, 2, 3],
        }
    }

    #[test]
    fn playlist_serialization_roundtrip() {
        let p = make_playlist(1);
        let bytes = encode_to_vec(&p, standard()).unwrap();
        let (decoded, _) = decode_from_slice::<Playlist, _>(&bytes, standard()).unwrap();
        assert_eq!(p, decoded);
    }

    #[test]
    fn playlist_empty_song_list() {
        let p = Playlist {
            id: 5,
            name: "Empty".into(),
            song_id_list: vec![],
        };
        let bytes = encode_to_vec(&p, standard()).unwrap();
        let (decoded, _) = decode_from_slice::<Playlist, _>(&bytes, standard()).unwrap();
        assert_eq!(p, decoded);
    }

    #[test]
    fn playlist_equality() {
        let a = make_playlist(1);
        let b = make_playlist(1);
        let c = Playlist {
            id: 2,
            name: "Other".into(),
            song_id_list: vec![4, 5],
        };
        assert_eq!(a, b);
        assert_ne!(a, c);
    }

    #[test]
    fn playlist_collection_serialization() {
        let mut map = HashMap::new();
        map.insert(1, make_playlist(1));
        let pc = PlaylistCollection {
            playlist_map: map,
            favourites_playlist_id: 0,
            favourites_cache: HashSet::from([1, 2]),
        };
        let bytes = encode_to_vec(&pc, standard()).unwrap();
        let (decoded, _) = decode_from_slice::<PlaylistCollection, _>(&bytes, standard()).unwrap();
        assert_eq!(pc.favourites_playlist_id, decoded.favourites_playlist_id);
        assert_eq!(decoded.favourites_cache.len(), 2);
    }

    #[test]
    fn playlist_collection_empty() {
        let pc = PlaylistCollection {
            playlist_map: HashMap::new(),
            favourites_playlist_id: 0,
            favourites_cache: HashSet::new(),
        };
        let bytes = encode_to_vec(&pc, standard()).unwrap();
        let (decoded, _) = decode_from_slice::<PlaylistCollection, _>(&bytes, standard()).unwrap();
        assert!(decoded.playlist_map.is_empty());
    }
}
