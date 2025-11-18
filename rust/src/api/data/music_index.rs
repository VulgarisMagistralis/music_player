use crate::api::data::song::Song;
use bincode::{
    config::standard,
    serde::{decode_from_slice, encode_to_vec},
};
use sled::Db;

pub struct MusicIndex {
    db: Db,
}

impl MusicIndex {
    pub fn new(path: &str) -> Self {
        let db = sled::open(path).expect("open sled db".into());
        Self { db }
    }

    pub fn add_song(&self, song: &Song) {
        let key = song.id.to_be_bytes();
        let value = encode_to_vec(song, standard()).unwrap();
        self.db.insert(key, value).unwrap();
    }

    pub fn get_song(&self, id: u64) -> Option<Song> {
        self.db
            .get(id.to_be_bytes())
            .ok()
            .flatten()
            .and_then(|ivec| {
                decode_from_slice(&ivec, standard())
                    .ok()
                    .map(|(song, _)| song)
            })
    }

    pub fn all_songs(&self) -> Vec<Song> {
        self.db
            .iter()
            .filter_map(|item| item.ok())
            .filter_map(|(_, v)| {
                decode_from_slice::<Song, _>(&v, standard())
                    .ok()
                    .map(|(song, _)| song)
            })
            .collect()
    }
}
