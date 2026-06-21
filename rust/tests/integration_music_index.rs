use rust_lib_music_player::api::data::{music_index::MusicIndex, song::Song};

fn make_song(id: u64, title: &str) -> Song {
    Song {
        id,
        path: format!("/music/track_{}.mp3", id),
        title: title.to_string(),
        artist: "Test Artist".into(),
        album: "Test Album".into(),
        last_modified_at: 1000 + id as i64,
        duration: Some(240),
        album_art_id: None,
    }
}

#[test]
fn music_index_add_and_get() {
    let dir = tempfile::tempdir().unwrap();
    let index = MusicIndex::new(dir.path().to_str().unwrap());

    let song = make_song(1, "Hello");
    index.add_song(&song);

    let result = index.get_song(1);
    assert!(result.is_some());
    let retrieved = result.unwrap();
    assert_eq!(retrieved.id, 1);
    assert_eq!(retrieved.title, "Hello");
}

#[test]
fn music_index_get_nonexistent() {
    let dir = tempfile::tempdir().unwrap();
    let index = MusicIndex::new(dir.path().to_str().unwrap());
    assert!(index.get_song(999).is_none());
}

#[test]
fn music_index_all_songs_empty() {
    let dir = tempfile::tempdir().unwrap();
    let index = MusicIndex::new(dir.path().to_str().unwrap());
    assert!(index.all_songs().is_empty());
}

#[test]
fn music_index_all_songs_multiple() {
    let dir = tempfile::tempdir().unwrap();
    let index = MusicIndex::new(dir.path().to_str().unwrap());

    for i in 0..5 {
        index.add_song(&make_song(i, &format!("Track {}", i)));
    }

    let all = index.all_songs();
    assert_eq!(all.len(), 5);
}

#[test]
fn music_index_overwrite_song() {
    let dir = tempfile::tempdir().unwrap();
    let index = MusicIndex::new(dir.path().to_str().unwrap());

    index.add_song(&make_song(1, "Original"));
    index.add_song(&make_song(1, "Updated"));

    let result = index.get_song(1).unwrap();
    assert_eq!(result.title, "Updated");
}

#[test]
fn music_index_various_fields() {
    let dir = tempfile::tempdir().unwrap();
    let index = MusicIndex::new(dir.path().to_str().unwrap());

    let song = Song {
        id: 42,
        path: "/path/song.flac".into(),
        title: "Long Title".into(),
        artist: "Some Artist.".into(),
        album: "".into(),
        last_modified_at: 999_999,
        duration: Some(600),
        album_art_id: Some(123),
    };
    index.add_song(&song);

    let result = index.get_song(42).unwrap();
    assert_eq!(result.duration, Some(600));
    assert_eq!(result.album_art_id, Some(123));
    assert_eq!(result.artist, "Some Artist.");
}

#[test]
fn music_index_no_duration() {
    let dir = tempfile::tempdir().unwrap();
    let index = MusicIndex::new(dir.path().to_str().unwrap());

    let song = Song {
        id: 7,
        path: "/music/unknown.mp3".into(),
        title: "Unknown".into(),
        artist: "".into(),
        album: "".into(),
        last_modified_at: 0,
        duration: None,
        album_art_id: None,
    };
    index.add_song(&song);

    let result = index.get_song(7).unwrap();
    assert!(result.duration.is_none());
}

#[test]
fn music_index_many_songs() {
    let dir = tempfile::tempdir().unwrap();
    let index = MusicIndex::new(dir.path().to_str().unwrap());

    for i in 0..100u64 {
        index.add_song(&make_song(i, &format!("Song {}", i)));
    }

    let all = index.all_songs();
    assert_eq!(all.len(), 100);
}
