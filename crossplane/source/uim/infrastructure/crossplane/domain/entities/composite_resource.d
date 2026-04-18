module uim.infrastructure.crossplane.domain.entities.composite_resource;

import uim.infrastructure.crossplane.domain.entities.managed_resource : ReadyCondition;

enum CompositeStatus {
    READY,
    NOT_READY,
    CREATING,
    DELETING,
    FAILED
}

struct ResourceRef {
    string resourceId;
    string name;
    string kind;
    ReadyCondition ready;
}

struct CompositeResource {
    string id;
    string name;
    string compositionId;
    string claimId;
    string[string] spec;
    ResourceRef[] resourceRefs;
    CompositeStatus status;
    string[string] connectionDetails;
    string createdAt;
    string updatedAt;

    uint readyCount() const {
        uint count;
        foreach (r; resourceRefs)
            if (r.ready == ReadyCondition.TRUE)
                count++;
        return count;
    }

    uint totalCount() const {
        return cast(uint) resourceRefs.length;
    }
}

unittest {
    auto refs = [
        ResourceRef("mr1", "bucket", "Bucket", ReadyCondition.TRUE),
        ResourceRef("mr2", "policy", "BucketPolicy", ReadyCondition.FALSE)
    ];
    auto xr = CompositeResource("xr1", "my-storage", "c1", "cl1",
        null, refs, CompositeStatus.NOT_READY, null,
        "2026-04-19T10:00:00Z", "2026-04-19T10:01:00Z");
    assert(xr.readyCount() == 1);
    assert(xr.totalCount() == 2);
    assert(xr.status == CompositeStatus.NOT_READY);
}
