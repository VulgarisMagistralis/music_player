use criterion::{criterion_group, criterion_main, Criterion};
use rust_lib_music_player::api::data::song::Song;
use bincode::config::standard;
use bincode::{decode_from_slice, encode_to_vec};

fn make_song(id: u64) -> Song {
    Song {
        id,
        path: "/music/track.mp3".into(),
        title: "Test Song".into(),
        artist: "Artist".into(),
        album: "Album".into(),
        last_modified_at: 1000,
        duration: Some(240),
        album_art_id: None,
    }
}

fn bench_xxhash_string(c: &mut Criterion) {
    let path = "/some/very/long/path/to/a/music/file/that/is/really.mp3";
    c.bench_function("xxhash64_string_80bytes", |b| {
        b.iter(|| xxhash_rust::xxh64::xxh64(path.as_bytes(), 0))
    });
}

fn bench_xxhash_short(c: &mut Criterion) {
    let s = "short";
    c.bench_function("xxhash64_string_5bytes", |b| {
        b.iter(|| xxhash_rust::xxh64::xxh64(s.as_bytes(), 0))
    });
}

fn bench_bincode_encode_song(c: &mut Criterion) {
    let song = make_song(1);
    c.bench_function("bincode_encode_song", |b| {
        b.iter(|| encode_to_vec(&song, standard()).unwrap())
    });
}

fn bench_bincode_decode_song(c: &mut Criterion) {
    let song = make_song(1);
    let bytes = encode_to_vec(&song, standard()).unwrap();
    c.bench_function("bincode_decode_song", |b| {
        b.iter(|| decode_from_slice::<Song, _>(&bytes, standard()).unwrap())
    });
}

fn bench_bincode_roundtrip_song(c: &mut Criterion) {
    let song = make_song(1);
    c.bench_function("bincode_roundtrip_song", |b| {
        b.iter(|| {
            let bytes = encode_to_vec(&song, standard()).unwrap();
            decode_from_slice::<Song, _>(&bytes, standard()).unwrap()
        })
    });
}

fn bench_bulk_xxxhash(c: &mut Criterion) {
    let paths: Vec<String> = (0..1000).map(|i| format!("/music/track_{}.mp3", i)).collect();
    c.bench_function("xxhash64_x1000_strings", |b| {
        b.iter(|| {
            for p in &paths {
                xxhash_rust::xxh64::xxh64(p.as_bytes(), 0);
            }
        })
    });
}

criterion_group!(
    benches,
    bench_xxhash_string,
    bench_xxhash_short,
    bench_bulk_xxxhash,
    bench_bincode_encode_song,
    bench_bincode_decode_song,
    bench_bincode_roundtrip_song
);
criterion_main!(benches);
