/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.gardener.infrastructure.adapters.inmemory;

import core.sync.mutex : Mutex;

import uim.infrastructure.gardener.domain.entities :
    Garden,
    Project,
    Secret,
    Certificate,
    Seed,
    Shoot;
import uim.infrastructure.gardener.domain.ports :
    IGardenRepository,
    IProjectRepository,
    ISecretRepository,
    ICertificateRepository,
    ISeedRepository,
    IShootRepository;

final class InMemoryGardenRepository : IGardenRepository {
    private Garden[] gardens;
    private Mutex mutex;

    this() {
        mutex = new Mutex();
    }

    Garden create(Garden garden) {
        mutex.lock();
        scope(exit) mutex.unlock();

        gardens ~= garden;
        return garden;
    }

    Garden[] list() {
        mutex.lock();
        scope(exit) mutex.unlock();

        return gardens.dup;
    }

    bool getByName(string name, out Garden garden) {
        mutex.lock();
        scope(exit) mutex.unlock();

        foreach (item; gardens) {
            if (item.name == name) {
                garden = item;
                return true;
            }
        }

        return false;
    }

    bool deleteByName(string name) {
        mutex.lock();
        scope(exit) mutex.unlock();

        Garden[] next;
        bool removed;
        foreach (item; gardens) {
            if (item.name == name) {
                removed = true;
                continue;
            }

            next ~= item;
        }

        if (removed) {
            gardens = next;
        }

        return removed;
    }
}

final class InMemoryProjectRepository : IProjectRepository {
    private Project[] projects;
    private Mutex mutex;

    this() {
        mutex = new Mutex();
    }

    Project create(Project project) {
        mutex.lock();
        scope(exit) mutex.unlock();

        projects ~= project;
        return project;
    }

    Project[] list() {
        mutex.lock();
        scope(exit) mutex.unlock();

        return projects.dup;
    }

    bool getByName(string name, out Project project) {
        mutex.lock();
        scope(exit) mutex.unlock();

        foreach (item; projects) {
            if (item.name == name) {
                project = item;
                return true;
            }
        }

        return false;
    }

    bool deleteByName(string name) {
        mutex.lock();
        scope(exit) mutex.unlock();

        Project[] next;
        bool removed;
        foreach (item; projects) {
            if (item.name == name) {
                removed = true;
                continue;
            }

            next ~= item;
        }

        if (removed) {
            projects = next;
        }

        return removed;
    }
}

final class InMemorySecretRepository : ISecretRepository {
    private Secret[] secrets;
    private Mutex mutex;

    this() {
        mutex = new Mutex();
    }

    Secret create(Secret secret) {
        mutex.lock();
        scope(exit) mutex.unlock();

        secrets ~= secret;
        return secret;
    }

    Secret[] list() {
        mutex.lock();
        scope(exit) mutex.unlock();

        return secrets.dup;
    }

    bool getByName(string name, out Secret secret) {
        mutex.lock();
        scope(exit) mutex.unlock();

        foreach (item; secrets) {
            if (item.name == name) {
                secret = item;
                return true;
            }
        }

        return false;
    }

    bool deleteByName(string name) {
        mutex.lock();
        scope(exit) mutex.unlock();

        Secret[] next;
        bool removed;
        foreach (item; secrets) {
            if (item.name == name) {
                removed = true;
                continue;
            }

            next ~= item;
        }

        if (removed) {
            secrets = next;
        }

        return removed;
    }
}

final class InMemoryCertificateRepository : ICertificateRepository {
    private Certificate[] certificates;
    private Mutex mutex;

    this() {
        mutex = new Mutex();
    }

    Certificate create(Certificate certificate) {
        mutex.lock();
        scope(exit) mutex.unlock();

        certificates ~= certificate;
        return certificate;
    }

    Certificate[] list() {
        mutex.lock();
        scope(exit) mutex.unlock();

        return certificates.dup;
    }

    bool getByName(string name, out Certificate certificate) {
        mutex.lock();
        scope(exit) mutex.unlock();

        foreach (item; certificates) {
            if (item.name == name) {
                certificate = item;
                return true;
            }
        }

        return false;
    }

    bool deleteByName(string name) {
        mutex.lock();
        scope(exit) mutex.unlock();

        Certificate[] next;
        bool removed;
        foreach (item; certificates) {
            if (item.name == name) {
                removed = true;
                continue;
            }

            next ~= item;
        }

        if (removed) {
            certificates = next;
        }

        return removed;
    }
}

final class InMemorySeedRepository : ISeedRepository {
    private Seed[] seeds;
    private Mutex mutex;

    this() {
        mutex = new Mutex();
    }

    Seed create(Seed seed) {
        mutex.lock();
        scope(exit) mutex.unlock();

        seeds ~= seed;
        return seed;
    }

    Seed[] list() {
        mutex.lock();
        scope(exit) mutex.unlock();

        return seeds.dup;
    }

    bool getByName(string name, out Seed seed) {
        mutex.lock();
        scope(exit) mutex.unlock();

        foreach (item; seeds) {
            if (item.name == name) {
                seed = item;
                return true;
            }
        }

        return false;
    }

    bool deleteByName(string name) {
        mutex.lock();
        scope(exit) mutex.unlock();

        Seed[] next;
        bool removed;
        foreach (item; seeds) {
            if (item.name == name) {
                removed = true;
                continue;
            }

            next ~= item;
        }

        if (removed) {
            seeds = next;
        }

        return removed;
    }
}

final class InMemoryShootRepository : IShootRepository {
    private Shoot[] shoots;
    private Mutex mutex;

    this() {
        mutex = new Mutex();
    }

    Shoot create(Shoot shoot) {
        mutex.lock();
        scope(exit) mutex.unlock();

        shoots ~= shoot;
        return shoot;
    }

    Shoot[] list() {
        mutex.lock();
        scope(exit) mutex.unlock();

        return shoots.dup;
    }

    bool getByName(string name, out Shoot shoot) {
        mutex.lock();
        scope(exit) mutex.unlock();

        foreach (item; shoots) {
            if (item.name == name) {
                shoot = item;
                return true;
            }
        }

        return false;
    }

    bool updateState(string name, string state, string updatedAt, out Shoot shoot) {
        mutex.lock();
        scope(exit) mutex.unlock();

        foreach (index, item; shoots) {
            if (item.name != name) {
                continue;
            }

            auto updated = item;
            updated.state = state;
            updated.updatedAt = updatedAt;
            shoots[index] = updated;
            shoot = updated;
            return true;
        }

        return false;
    }

    bool deleteByName(string name) {
        mutex.lock();
        scope(exit) mutex.unlock();

        Shoot[] next;
        bool removed;
        foreach (item; shoots) {
            if (item.name == name) {
                removed = true;
                continue;
            }

            next ~= item;
        }

        if (removed) {
            shoots = next;
        }

        return removed;
    }
}
