/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.infrastructure.persistence.memory.user_repository;

import core.sync.mutex : Mutex;
import std.string : toLower;
import uim.infrastructure.scim.domain.entities.user : ScimUser;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;

class InMemoryUserRepository : IUserRepository {
    private ScimUser[] users;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(ScimUser user) {
        synchronized (mutex) {
            foreach (index, existing; users) {
                if (existing.id == user.id) {
                    users[index] = user;
                    return;
                }
            }
            users ~= user;
        }
    }

    override ScimUser[] list() {
        synchronized (mutex) {
            return users.dup;
        }
    }

    override ScimUser* findById(string id) {
        synchronized (mutex) {
            foreach (ref user; users) {
                if (user.id == id) {
                    return clone(user);
                }
            }
            return null;
        }
    }

    override ScimUser* findByUserName(string userName) {
        synchronized (mutex) {
            foreach (ref user; users) {
                if (toLower(user.userName) == toLower(userName)) {
                    return clone(user);
                }
            }
            return null;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            ScimUser[] remaining;
            foreach (user; users) {
                if (user.id != id) {
                    remaining ~= user;
                }
            }
            users = remaining;
        }
    }

    private ScimUser* clone(ScimUser user) {
        return new ScimUser(
            user.id,
            user.externalId,
            user.userName,
            user.displayName,
            user.givenName,
            user.familyName,
            user.emails.dup,
            user.createdAt,
            user.lastModifiedAt,
            user.versionTag
        );
    }
}

unittest {
    import std.datetime : Clock;

    auto repo = new InMemoryUserRepository();
    repo.save(
        ScimUser(
            "u1",
            "external",
            "jsmith",
            "John Smith",
            "John",
            "Smith",
            ["jsmith@example.com"],
            Clock.currTime(),
            Clock.currTime(),
            "W/\"v1\""
        )
    );
    assert(repo.list().length == 1);
    assert(repo.findById("u1") !is null);
    assert(repo.findByUserName("JSMITH") !is null);
    repo.remove("u1");
    assert(repo.findById("u1") is null);
}
