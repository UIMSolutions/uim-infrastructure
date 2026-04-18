module uim.infrastructure.crossplane.infrastructure.persistence.memory.composite_resource_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.crossplane.domain.entities.composite_resource : CompositeResource, ResourceRef;
import uim.infrastructure.crossplane.domain.ports.repositories.composite_resource : ICompositeResourceRepository;

class InMemoryCompositeResourceRepository : ICompositeResourceRepository {
    private CompositeResource[] resources;
    private Mutex mutex;

    this() { mutex = new Mutex; }

    private CompositeResource copyResource(in CompositeResource xr) {
        string[string] spec;
        foreach (k, v; xr.spec) spec[k] = v;
        ResourceRef[] refs;
        foreach (r; xr.resourceRefs)
            refs ~= ResourceRef(r.resourceId, r.name, r.kind, r.ready);
        string[string] connDetails;
        foreach (k, v; xr.connectionDetails) connDetails[k] = v;
        return CompositeResource(xr.id, xr.name, xr.compositionId, xr.claimId,
            spec, refs, xr.status, connDetails, xr.createdAt, xr.updatedAt);
    }

    override void save(in CompositeResource resource) {
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
            CompositeResource[] filtered;
            foreach (r; resources) if (r.id != id) filtered ~= r;
            resources = filtered;
        }
    }

    override CompositeResource[] list() {
        synchronized (mutex) { return resources.dup; }
    }

    override CompositeResource* findById(string id) {
        synchronized (mutex) {
            foreach (ref r; resources) if (r.id == id) return &r;
            return null;
        }
    }

    override CompositeResource[] findByCompositionId(string compositionId) {
        synchronized (mutex) {
            CompositeResource[] result;
            foreach (r; resources) if (r.compositionId == compositionId) result ~= r;
            return result;
        }
    }
}

unittest {
    import uim.infrastructure.crossplane.domain.entities.composite_resource : CompositeStatus;
    import uim.infrastructure.crossplane.domain.entities.managed_resource : ReadyCondition;

    auto repo = new InMemoryCompositeResourceRepository();
    auto xr = CompositeResource("xr1", "my-xr", "c1", "cl1", null,
        [ResourceRef("mr1", "bucket", "Bucket", ReadyCondition.TRUE)],
        CompositeStatus.READY, null, "2026-04-19", "2026-04-19");
    repo.save(xr);
    assert(repo.list().length == 1);
    assert(repo.findByCompositionId("c1").length == 1);
    repo.remove("xr1");
    assert(repo.list().length == 0);
}
