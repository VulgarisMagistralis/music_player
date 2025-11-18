use crate::api::error::custom_error::CustomError;
use crate::api::utils::database_ops::{
    get_music_folders_from_db, save_music_folder_to_db, set_db_dir,
};
use std::path::PathBuf;
use std::sync::OnceLock;
static APP_DATA_DIR: OnceLock<PathBuf> = OnceLock::new();

#[flutter_rust_bridge::frb()]
pub fn set_application_data_directory(path: String) -> Result<(), CustomError> {
    let _ = APP_DATA_DIR
        .set(PathBuf::from(&path))
        .map_err(|_| CustomError::AlreadyInitialized("App data dir already set".into()));

    let mut db_path = PathBuf::from(&path);
    db_path.push("library_db");
    set_db_dir(db_path.to_string_lossy().to_string()).map_err(|e| CustomError::DbError(e))?;
    Ok(())
}

#[flutter_rust_bridge::frb()]
pub fn save_music_folder_list(folders: Vec<String>) -> Result<(), CustomError> {
    for folder_path in folders {
        save_music_folder_to_db(&folder_path)?;
    }
    Ok(())
}

#[flutter_rust_bridge::frb()]
pub fn get_music_folder_list() -> Result<Vec<String>, CustomError> {
    get_music_folders_from_db()
}
