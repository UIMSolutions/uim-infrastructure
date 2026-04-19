module uim.infrastructure.odata.infrastructure.adapters.inmemory.entity_repository;

import core.sync.mutex : Mutex;
import std.algorithm : sort, filter;
import std.array : array;
import std.conv : to;
import std.string : indexOf, toLower;
import uim.infrastructure.odata.domain.entities.entity : Entity;
import uim.infrastructure.odata.domain.entities.query_options : QueryOptions;
import uim.infrastructure.odata.domain.ports.repositories.entity : IEntityRepository;

class InMemoryEntityRepository : IEntityRepository {
    private Entity[][string] store;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    void save(string entitySetName, in Entity entity) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (entitySetName !in store) {
            store[entitySetName] = [];
        }
        store[entitySetName] ~= cast(Entity) entity;
    }

    void update(string entitySetName, string id, in Entity entity) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (entitySetName !in store) return;
        foreach (ref e; store[entitySetName]) {
            if (e.id == id) {
                e = cast(Entity) entity;
                return;
            }
        }
    }

    Entity[] list(string entitySetName) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (entitySetName !in store) return [];
        return store[entitySetName].dup;
    }

    Entity* findById(string entitySetName, string id) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (entitySetName !in store) return null;
        foreach (ref e; store[entitySetName]) {
            if (e.id == id) return &e;
        }
        return null;
    }

    void deleteById(string entitySetName, string id) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (entitySetName !in store) return;
        Entity[] filtered;
        foreach (e; store[entitySetName]) {
            if (e.id != id) filtered ~= e;
        }
        store[entitySetName] = filtered;
    }

    Entity[] query(string entitySetName, in QueryOptions options) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (entitySetName !in store) return [];

        Entity[] results = store[entitySetName].dup;

        // Apply $filter (simple eq support)
        if (options.filter.length > 0) {
            results = applyFilter(results, options.filter);
        }

        // Apply $search
        if (options.search.length > 0) {
            results = applySearch(results, options.search);
        }

        // Apply $orderby
        if (options.orderby.length > 0) {
            results = applyOrderBy(results, options.orderby);
        }

        // Apply $skip
        if (options.hasSkip && options.skip > 0) {
            if (options.skip >= results.length)
                results = [];
            else
                results = results[options.skip .. $];
        }

        // Apply $top
        if (options.hasTop && options.top < results.length) {
            results = results[0 .. options.top];
        }

        return results;
    }

    ulong count(string entitySetName) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (entitySetName !in store) return 0;
        return cast(ulong) store[entitySetName].length;
    }

    private Entity[] applyFilter(Entity[] entities, string filterExpr) {
        // Simple parser: "PropertyName eq 'value'"
        auto eqIdx = filterExpr.indexOf(" eq ");
        if (eqIdx < 0) return entities;

        auto propName = filterExpr[0 .. eqIdx];
        auto valueStr = filterExpr[eqIdx + 4 .. $];

        // Remove surrounding quotes
        if (valueStr.length >= 2 && valueStr[0] == '\'') {
            valueStr = valueStr[1 .. $ - 1];
        }

        Entity[] filtered;
        foreach (e; entities) {
            if (propName in e.properties && e.properties[propName] == valueStr) {
                filtered ~= e;
            }
        }
        return filtered;
    }

    private Entity[] applySearch(Entity[] entities, string search) {
        auto lowerSearch = search.toLower();
        Entity[] filtered;
        foreach (e; entities) {
            foreach (k, v; e.properties) {
                if (v.toLower().indexOf(lowerSearch) >= 0) {
                    filtered ~= e;
                    break;
                }
            }
        }
        return filtered;
    }

    private Entity[] applyOrderBy(Entity[] entities, string orderby) {
        // Simple: "PropertyName asc" or "PropertyName desc"
        auto spaceIdx = orderby.indexOf(' ');
        string propName;
        bool descending = false;

        if (spaceIdx < 0) {
            propName = orderby;
        } else {
            propName = orderby[0 .. spaceIdx];
            auto dir = orderby[spaceIdx + 1 .. $];
            descending = (dir == "desc");
        }

        entities.sort!((a, b) {
            string va = propName in a.properties ? a.properties[propName] : "";
            string vb = propName in b.properties ? b.properties[propName] : "";
            if (descending) return va > vb;
            return va < vb;
        });

        return entities;
    }
}
