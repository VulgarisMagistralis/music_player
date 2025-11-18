use thiserror::Error;

#[derive(Debug, Error)]
pub enum CustomError {
    #[error("Database error: {0}")]
    DbError(String),

    #[error("Failed to decode stored folder name as UTF-8")]
    Utf8Error,

    #[error("Invalid folder path: {0}")]
    InvalidPath(String),

    #[error("Failed to open tree: {0}")]
    TreeError(String),

    #[error("Failed to decode")]
    DecodeError,

    #[error("{0}")]
    AlreadyInitialized(String),

    #[error("Failed to encode")]
    EncodeError,

    #[error("{0}")]
    PlaylistCollectionError(String),

    #[error("Failed to load album art")]
    AlbumArtError,

    #[error("Unknown error: {0}")]
    Unknown(String),
}

pub type ResultT<T> = Result<T, CustomError>;
