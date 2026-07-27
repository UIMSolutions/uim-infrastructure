/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.barbican.infrastructure.persistence.memory.secret_repository;

import core.sync.mutex : Mutex;
import std.datetime : Clock;
import uim.infrastructure.barbican.domain.entities.secret : Secret, SecretType, SecretStatus;
import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

class InMemorySecretRepository : ISecretRepository {
    private Secret[] secrets;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Secret secret) {
        synchronized (mutex) {
            foreach (i, ref existing; secrets) {
                if (existing.id == secret.id) {
                    secrets[i] = copySecret(secret);
                    return;
                }
            }
            secrets ~= copySecret(secret);
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Secret[] filtered;
            foreach (s; secrets) {
                if (s.id != id)
                    filtered ~= s;
            }
            secrets = filtered;
        }
    }

    override Secret[] list(string projectId = "") {
        synchronized (mutex) {
            if (projectId.length == 0)
                return secrets.dup;
            Secret[] result;
            foreach (s; secrets) {
                if (s.projectId == projectId)
                    result ~= s;
            }
            return result;
        }
    }

    override Secret* findById(string id) {
        synchronized (mutex) {
            foreach (ref s; secrets) {
                if (s.id == id)
                    return &s;
            }
            return null;
        }
    }

    override Secret[] findByStatus(SecretStatus status) {
        synchronized (mutex) {
            Secret[] result;
            foreach (s; secrets) {
                if (s.status == status)
                    result ~= s;
            }
            return result;
        }
    }

    override Secret[] findByType(SecretType secretType) {
        synchronized (mutex) {
            Secret[] result;
            foreach (s; secrets) {
                if (s.secretType == secretType)
                    result ~= s;
            }
            return result;
        }
    }

    override bool setPayload(string id, string payload, string contentType) {
        synchronized (mutex) {
            foreach (ref s; secrets) {
                if (s.id == id) {
                    s.payload = payload;
                    s.payloadContentType = contentType;
                    s.updatedAt = Clock.currTime.toISOExtString();
                    return true;
                }
            }
            return false;
        }
    }

    private Secret copySecret(in Secret src) {
        Secret dst;
        dst.id = src.id;
        dst.name = src.name;
        dst.secretType = src.secretType;
        dst.algorithm = src.algorithm;
        dst.bitLength = src.bitLength;
        dst.mode = src.mode;
        dst.payload = src.payload;
        dst.payloadContentType = src.payloadContentType;
        dst.expiration = src.expiration;
        dst.status = src.status;
        dst.createdAt = src.createdAt;
        dst.updatedAt = src.updatedAt;
        dst.projectId = src.projectId;
        return dst;
    }
}
