use std::sync::OnceLock;
use std::path::PathBuf;
use std::fs;

static APP_DATA_DIR: OnceLock<PathBuf> = OnceLock::new();

#[flutter_rust_bridge::frb(sync)]
pub fn set_application_data_directory(path: String) -> Result<(), String> {
    let dir = PathBuf::from(path);
    ///! 
    if APP_DATA_DIR.set(dir).is_err() {
        eprintln!("App data dir already set");
    }
    Ok(())
}

fn get_app_dir() -> Option<&'static PathBuf> {
    APP_DATA_DIR.get()
}

#[flutter_rust_bridge::frb(sync)]
pub fn save_music_folder_list(folders: Vec<String>) -> Result<(), String> {
    let Some(app_dir) = get_app_dir() else {
        eprintln!("App data dir not set");
        return Ok(());
    };

    let file_path = app_dir.join("music_folders.json");
    if let Err(e) = fs::create_dir_all(app_dir) {
        eprintln!("Failed to create dir: {e}");
        return Ok(());
    }

    let Ok(json_data) = serde_json::to_string(&folders) else {
        eprintln!("Failed to serialize folders");
        return Ok(());
    };

    if let Err(e) = fs::write(&file_path, json_data) {
        eprintln!("Failed to write file: {e}");
    }

    Ok(())
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_music_folder_list() -> Result<Vec<String>, String> {
    let Some(app_dir) = get_app_dir() else {
        eprintln!("App data dir not set");
        return Ok(vec![]);
    };

    let file_path = app_dir.join("music_folders.json");
    if !file_path.exists() {
        return Ok(vec![]);
    }

    let content = match fs::read_to_string(file_path) {
        Ok(c) => c,
        Err(_) => return Ok(vec![]),
    };

    let folders: Vec<String> = serde_json::from_str(&content).unwrap_or_default();
    Ok(folders)
}
