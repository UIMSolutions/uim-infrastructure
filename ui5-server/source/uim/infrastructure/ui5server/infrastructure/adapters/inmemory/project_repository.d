/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.infrastructure.adapters.inmemory.project_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ui5server.domain.entities.project : Project;
import uim.infrastructure.ui5server.domain.ports.repositories.project : IProjectRepository;

class InMemoryProjectRepository : IProjectRepository {
    private Project[string] store;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    bool save(Project project) {
        mtx.lock();
        scope(exit) mtx.unlock();
        store[project.id] = project;
        return true;
    }

    Project* findById(string id) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = id in store;
        return p;
    }

    Project* findByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        foreach (ref p; store) {
            if (p.name == name) return &p;
        }
        return null;
    }

    Project[] findAll() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return store.values;
    }

    bool remove(string id) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (id in store) {
            store.remove(id);
            return true;
        }
        return false;
    }
}
