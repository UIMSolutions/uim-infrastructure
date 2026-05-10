module uim.infrastructure.barbican.infrastructure.persistence.memory.secret_container_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.barbican.domain.entities.secret_container : SecretContainer, SecretRef;
import uim.infrastructure.barbican.domain.ports.repositories.secret_container : ISecretContainerRepository;

class InMemorySecretContainerRepository : ISecretContainerRepository {
    private SecretContainer[] containers;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in SecretContainer container) {
        synchronized (mutex) {
            foreach (i, ref existing; containers) {
                if (existing.id == container.id) {
                    containers[i] = copyContainer(container);
                    return;
                }
            }
            containers ~= copyContainer(container);
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            SecretContainer[] filtered;
            foreach (c; containers) {
                if (c.id != id)
                    filtered ~= c;
            }
            containers = filtered;
        }
    }

    override SecretContainer[] list(string projectId = "") {
        synchronized (mutex) {
            if (projectId.length == 0)
                return containers.dup;
            SecretContainer[] result;
            foreach (c; containers) {
                if (c.projectId == projectId)
                    result ~= c;
            }
            return result;
        }
    }

    override SecretContainer* findById(string id) {
        synchronized (mutex) {
            foreach (ref c; containers) {
                if (c.id == id)
                    return &c;
            }
            return null;
        }
    }

    private SecretContainer copyContainer(in SecretContainer src) {
        SecretContainer dst;
        dst.id = src.id;
        dst.name = src.name;
        dst.containerType = src.containerType;
        dst.createdAt = src.createdAt;
        dst.updatedAt = src.updatedAt;
        dst.projectId = src.projectId;
        foreach (ref r; src.secretRefs) {
            SecretRef sr;
            sr.name = r.name;
            sr.secretId = r.secretId;
            dst.secretRefs ~= sr;
        }
        return dst;
    }
}
