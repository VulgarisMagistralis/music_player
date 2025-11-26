use crate::api::error::custom_error::CustomError;
use crate::api::utils::database_ops::get_music_folders_from_db;
use crate::api::utils::database_ops::remove_music_folder_from_db;
use crate::api::utils::database_ops::{save_music_folder_to_db, set_db_dir};
use log::info;
use std::path::PathBuf;
use std::sync::OnceLock;
static APP_DATA_DIR: OnceLock<PathBuf> = OnceLock::new();

#[flutter_rust_bridge::frb()]
pub fn set_app_directory(path: String) -> Result<(), CustomError> {
    info!("App dir: {}", path);
    let _ = APP_DATA_DIR.set(PathBuf::from(&path)).map_err(|_| {
        info!("App data dir already set");
        CustomError::AlreadyInitialized("App data dir already set".into())
    });
    let mut db_path = PathBuf::from(&path);
    db_path.push("library_db");
    info!("{}", format!("{}", db_path.to_string_lossy()));
    set_db_dir(db_path.to_string_lossy().to_string()).map_err(|e| CustomError::DbError(e))?;
    Ok(())
}

#[flutter_rust_bridge::frb()]
pub fn save_music_folder_list(folders: Vec<String>) -> Result<(), CustomError> {
    for folder_path in folders {
        info!("{}", format!("{}", folder_path));
        save_music_folder_to_db(&folder_path)?;
    }
    Ok(())
}

#[flutter_rust_bridge::frb()]
pub fn delete_music_folder_list(folder: String) -> Result<(), CustomError> {
    remove_music_folder_from_db(folder)?;
    Ok(())
}

#[flutter_rust_bridge::frb()]
pub fn get_music_folder_list() -> Result<Vec<String>, CustomError> {
    get_music_folders_from_db()
}
