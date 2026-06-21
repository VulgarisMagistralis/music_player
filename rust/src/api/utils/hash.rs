use xxhash_rust::xxh64::xxh64;

/// Generate a stable 64-bit hash from the string using xxHash64
pub(crate) fn hash_string(string: &str) -> u64 {
    let bytes = string.as_bytes();
    xxh64(bytes, 0)
}

pub(crate) fn hash_bytes(bytes: &[u8]) -> u64 {
    xxh64(bytes, 0)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn hash_string_deterministic() {
        let s = "the same string";
        assert_eq!(hash_string(s), hash_string(s));
    }

    #[test]
    fn hash_string_different_inputs() {
        assert_ne!(hash_string("hello"), hash_string("world"));
    }

    #[test]
    fn hash_string_empty_returns_zero_seed() {
        let a = hash_string("");
        let b = hash_bytes(&[]);
        assert_eq!(a, b);
    }

    #[test]
    fn hash_bytes_same_as_string() {
        let s = "hello";
        assert_eq!(hash_string(s), hash_bytes(s.as_bytes()));
    }

    #[test]
    fn hash_string_case_sensitive() {
        assert_ne!(hash_string("Foo"), hash_string("foo"));
    }

    #[test]
    fn hash_string_unicode() {
        let s = "caf\u{00e9}";
        let a = hash_string(s);
        let b = hash_bytes(s.as_bytes());
        assert_eq!(a, b);
    }

    #[test]
    fn hash_bytes_randomness_distribution() {
        let mut set = std::collections::HashSet::new();
        for i in 0..100u64 {
            set.insert(hash_string(&i.to_string()));
        }
        assert!(set.len() == 100);
    }
}
