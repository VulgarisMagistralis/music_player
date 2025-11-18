use xxhash_rust::xxh64::xxh64;

/// Generate a stable 64-bit hash from the string using xxHash64
pub(crate) fn hash_string(string: &str) -> u64 {
    let bytes = string.as_bytes();
    xxh64(bytes, 0)
}
