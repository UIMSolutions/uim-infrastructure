module redis_service.domain.entities.cache_entry;

import std.datetime.systime : Clock;

/// A single key-value entry stored in the cache.
/// When expiresAtUnixMs is 0 the entry never expires.
struct CacheEntry {
    string key;
    string value;
    long expiresAtUnixMs;

    bool isExpired() const {
        if (expiresAtUnixMs == 0) {
            return false;
        }
        return Clock.currTime().toUnixTime!long * 1000 > expiresAtUnixMs;
    }
}

unittest {
    import std.datetime.systime : Clock;

    auto entry = CacheEntry("foo", "bar", 0);
    assert(!entry.isExpired());

    long pastMs = (Clock.currTime().toUnixTime!long - 10) * 1000;
    auto expired = CacheEntry("baz", "qux", pastMs);
    assert(expired.isExpired());
}
