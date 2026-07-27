/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.infrastructure.adapters.inmemory.resource_repository;

import core.sync.mutex : Mutex;
import std.string : startsWith;
import uim.infrastructure.ui5server.domain.entities.resource : Resource;
import uim.infrastructure.ui5server.domain.ports.repositories.resource : IResourceRepository;

class InMemoryResourceRepository : IResourceRepository {
    private Resource[string] store;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    bool save(Resource resource) {
        mtx.lock();
        scope(exit) mtx.unlock();
        store[resource.path] = resource;
        return true;
    }

    Resource* findByPath(string path) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = path in store;
        return p;
    }

    Resource[] findByDirectory(string directoryPath) {
        mtx.lock();
        scope(exit) mtx.unlock();
        Resource[] results;
        auto prefix = directoryPath;
        if (prefix.length > 0 && prefix[$ - 1] != '/') prefix ~= "/";
        foreach (ref r; store) {
            if (r.path.startsWith(prefix) && r.path != directoryPath) {
                // Only direct children (no deeper nesting)
                auto rest = r.path[prefix.length .. $];
                import std.string : indexOf;
                auto slashIdx = rest.indexOf('/');
                if (slashIdx < 0 || slashIdx == cast(ptrdiff_t)(rest.length - 1)) {
                    results ~= r;
                }
            }
        }
        return results;
    }

    Resource[] findAll() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return store.values;
    }

    bool remove(string path) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (path in store) {
            store.remove(path);
            return true;
        }
        return false;
    }

    bool exists(string path) {
        mtx.lock();
        scope(exit) mtx.unlock();
        return (path in store) !is null;
    }
}
