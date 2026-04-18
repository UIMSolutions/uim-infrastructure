module uim.infrastructure.crossplane.infrastructure.persistence.memory.managed_resource_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.crossplane.domain.entities.managed_resource : ManagedResource;
import uim.infrastructure.crossplane.domain.ports.repositories.managed_resource : IManagedResourceRepository;

class InMemoryManagedResourceRepository : IManagedResourceRepository {
    private ManagedResource[] resources;
    private Mutex mutex;

    this() { mutex = new Mutex; }

    private ManagedResource copyResource(in ManagedResource r) {
        string[string] spec;
        foreach (k, v; r.spec) spec[k] = v;
        string[string] sf;
        foreach (k, v; r.statusFields) sf[k] = v;
        return ManagedResource(r.id, r.name, r.providerId, r.apiGroup, r.kind,
            spec, sf, r.status, r.ready, r.externalName, r.compositeRef,
            r.createdAt, r.updatedAt);
    }

    override void save(in ManagedResource resource) {
        synchronized (mutex) {
            auto copy = copyResource(resource);
            foreach (i, ref existing; resources) {
                if (existing.id == resource.id) { resources[i] = copy; return; }
            }
            resources ~= copy;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            ManagedResource[] filtered;
            foreach (r; resources) if (r.id != id) filtered ~= r;
            resources = filtered;
        }
    }

    override ManagedResource[] list() {
        synchronized (mutex) { return resources.dup; }
    }

    override ManagedResource* findById(string id) {
        synchronized (mutex) {
            foreach (ref r; resources) if (r.id == id) return &r;
            return null;
        }
    }

    override ManagedResource[] findByProviderId(string providerId) {
        synchronized (mutex) {
            ManagedResource[] result;
            foreach (r; resources) if (r.providerId == providerId) result ~= r;
            return result;
        }
    }

    override ManagedResource[] findByCompositeRef(string compositeRef) {
        synchronized (mutex) {
            ManagedResource[] result;
            foreach (r; resources) if (r.compositeRef == compositeRef) result ~= r;
            return result;
        }
    }
}

unittest {
    import uim.infrastructure.crossplane.domain.entities.managed_resource : ResourceStatus, ReadyCondition;

    auto repo = new InMemoryManagedResourceRepository();
    string[string] spec;
    spec["size"] = "100Gi";
    auto mr = ManagedResource("mr1", "my-bucket", "p1", "s3.aws", "Bucket",
        spec, null, ResourceStatus.AVAILABLE, ReadyCondition.TRUE, "my-bucket", "",
        "2026-04-19", "2026-04-19");
    repo.save(mr);
    assert(repo.list().length == 1);
    assert(repo.findById("mr1") !is null);
    assert(repo.findByProviderId("p1").length == 1);
    repo.remove("mr1");
    assert(repo.list().length == 0);
}
