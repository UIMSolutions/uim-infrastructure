module uim.infrastructure.manila.domain.entities.quota_set;

struct QuotaSet {
    string projectId;
    uint maxShares;
    ulong maxShareGigabytes;
    uint maxSnapshots;
    uint usedShares;
    ulong usedShareGigabytes;
    uint usedSnapshots;
}

unittest {
    auto quota = QuotaSet("project-a", 50, 1024, 100, 2, 80, 1);
    assert(quota.usedShareGigabytes == 80);
}