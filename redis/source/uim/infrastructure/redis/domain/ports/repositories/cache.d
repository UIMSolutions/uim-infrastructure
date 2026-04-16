module redis_service.domain.ports.repositories.cache;

import redis_service.domain.entities.cache_entry : CacheEntry;
import std.typecons : Nullable;

interface ICacheRepository {
    void set(in CacheEntry entry);
    Nullable!CacheEntry get(string key);
    void remove(string key);
    string[] listKeys();
}
