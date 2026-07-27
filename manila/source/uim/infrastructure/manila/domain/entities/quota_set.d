/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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