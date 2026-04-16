module redis_service.infrastructure.persistence.memory.cache_repository;

import core.sync.mutex : Mutex;
import redis_service.domain.entities.cache_entry : CacheEntry;
import redis_service.domain.ports.repositories.cache : ICacheRepository;
import std.datetime.systime : Clock;
import std.typecons : Nullable, nullable;

class InMemoryCacheRepository : ICacheRepository {
    private CacheEntry[string] store;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void set(in CacheEntry entry) {
        synchronized (mutex) {
            store[entry.key] = entry;
        }
    }

    override Nullable!CacheEntry get(string key) {
        synchronized (mutex) {
            auto ptr = key in store;
            if (ptr is null) {
                return Nullable!CacheEntry.init;
            }
            if (ptr.isExpired()) {
                store.remove(key);
                return Nullable!CacheEntry.init;
            }
            return nullable(*ptr);
        }
    }

    override void remove(string key) {
        synchronized (mutex) {
            store.remove(key);
        }
    }

    override string[] listKeys() {
        synchronized (mutex) {
            immutable nowMs = Clock.currTime().toUnixTime!long * 1000;
            string[] expired;
            foreach (key, ref entry; store) {
                if (entry.expiresAtUnixMs != 0 && nowMs > entry.expiresAtUnixMs) {
                    expired ~= key;
                }
            }
            foreach (k; expired) {
                store.remove(k);
            }
            return store.keys.dup;
        }
    }
}

unittest {
    auto repo = new InMemoryCacheRepository();

    repo.set(CacheEntry("name", "alice", 0));
    repo.set(CacheEntry("city", "berlin", 0));

    assert(repo.listKeys().length == 2);

    auto entry = repo.get("name");
    assert(!entry.isNull);
    assert(entry.get.value == "alice");

    repo.remove("name");
    assert(repo.get("name").isNull);
    assert(repo.listKeys().length == 1);

    // Upsert: saving the same key again replaces the value.
    repo.set(CacheEntry("city", "paris", 0));
    assert(repo.get("city").get.value == "paris");
}
