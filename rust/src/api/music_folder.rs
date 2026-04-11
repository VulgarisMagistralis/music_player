use crate::api::error::custom_error::CustomError;
use crate::api::utils::database_ops::get_music_folders_from_db;
use crate::api::utils::database_ops::remove_music_folder_from_db;
use crate::api::utils::database_ops::{save_music_folder_to_db, set_db_dir};
use log::info;
use std::path::PathBuf;
use std::sync::OnceLock;
static APP_DATA_DIR: OnceLock<PathBuf> = OnceLock::new();
static APP_CACHE_DIR: OnceLock<PathBuf> = OnceLock::new();

#[flutter_rust_bridge::frb()]
pub fn set_app_directory(
    application_directory: String,
    cache_directory: String,
) -> Result<(), CustomError> {
    info!("App dir: {}", application_directory);
    let _ = APP_DATA_DIR
        .set(PathBuf::from(&application_directory))
        .map_err(|_| {
            info!("App data dir already set");
            CustomError::AlreadyInitialized("App data dir already set".into())
        });
    let _ = APP_CACHE_DIR
        .set(PathBuf::from(&cache_directory))
        .map_err(|_| {
            info!("App cache dir already set");
            CustomError::AlreadyInitialized("App data dir already set".into())
        });
    let mut db_path = PathBuf::from(&application_directory);
    db_path.push("library_db");
    info!("{}", format!("{}", db_path.to_string_lossy()));
    set_db_dir(db_path.to_string_lossy().to_string()).map_err(|e| CustomError::DbError(e))?;
    Ok(())
}

pub fn get_thumbnails_dir() -> Result<PathBuf, CustomError> {
    let base_path = APP_CACHE_DIR
        .get()
        .ok_or_else(|| CustomError::InvalidPath("App data directory not initialized".into()))?;
    let thumb_path = base_path.join("thumbnails");
    if !thumb_path.exists() {
        std::fs::create_dir_all(&thumb_path)
            .map_err(|e| CustomError::InvalidPath(e.to_string()))?;
    }
    Ok(thumb_path)
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
