use crate::api::data::song::Song;
use serde::{Deserialize, Serialize};

#[flutter_rust_bridge::frb()]
#[derive(Serialize, Deserialize, Clone, Debug)]
pub enum StreamEvent {
    Song(Song),
    Error(String),
    Done,
}
