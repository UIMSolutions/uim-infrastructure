/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.maia.domain.entities.tenant;

/// Authentication and authorization scope extracted from an OpenStack token.
struct Tenant {
    string projectId;
    string domainId;

    /// A domain-scoped tenant has a domainId but no projectId.
    bool isDomainScoped() const { return domainId.length > 0 && projectId.length == 0; }
    bool isProjectScoped() const { return projectId.length > 0; }
}

unittest {
    auto proj = Tenant("proj-001", "");
    assert(proj.isProjectScoped());
    assert(!proj.isDomainScoped());

    auto dom = Tenant("", "dom-001");
    assert(dom.isDomainScoped());
    assert(!dom.isProjectScoped());
}
