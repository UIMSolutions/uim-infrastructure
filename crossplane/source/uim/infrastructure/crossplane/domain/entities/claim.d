module uim.infrastructure.crossplane.domain.entities.claim;

enum ClaimStatus {
    PENDING,
    BOUND,
    FAILED,
    DELETING
}

struct Claim {
    string id;
    string name;
    string namespace;
    string compositeRef;
    string compositionRef;
    string[string] parameters;
    ClaimStatus status;
    string boundResourceId;
    string createdAt;
    string updatedAt;
}

unittest {
    string[string] params;
    params["region"] = "us-east-1";
    params["storageSize"] = "100Gi";
    auto cl = Claim("cl1", "my-database", "team-a", "", "rds-composition",
        params, ClaimStatus.BOUND, "xr1", "2026-04-19T10:00:00Z", "2026-04-19T10:01:00Z");
    assert(cl.name == "my-database");
    assert(cl.status == ClaimStatus.BOUND);
    assert(cl.boundResourceId == "xr1");
}
