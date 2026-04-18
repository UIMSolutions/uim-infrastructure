module uim.infrastructure.crossplane.domain.entities.managed_resource;

enum ResourceStatus {
    AVAILABLE,
    CREATING,
    DELETING,
    UPDATING,
    FAILED,
    UNKNOWN
}

enum ReadyCondition {
    TRUE,
    FALSE,
    UNKNOWN
}

struct ManagedResource {
    string id;
    string name;
    string providerId;
    string apiGroup;
    string kind;
    string[string] spec;
    string[string] statusFields;
    ResourceStatus status;
    ReadyCondition ready;
    string externalName;
    string compositeRef;
    string createdAt;
    string updatedAt;
}

unittest {
    string[string] spec;
    spec["bucketName"] = "my-bucket";
    spec["region"] = "us-east-1";
    auto mr = ManagedResource("mr1", "my-s3-bucket", "p1", "s3.aws.crossplane.io",
        "Bucket", spec, null, ResourceStatus.AVAILABLE, ReadyCondition.TRUE,
        "my-bucket", "", "2026-04-19T10:00:00Z", "2026-04-19T10:01:00Z");
    assert(mr.name == "my-s3-bucket");
    assert(mr.status == ResourceStatus.AVAILABLE);
    assert(mr.ready == ReadyCondition.TRUE);
}
