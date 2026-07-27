/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.domain.ports.repositories.rbac_policy;

import uim.infrastructure.archer.domain.entities.rbac_policy : ArcherRbacPolicy;

interface IRbacPolicyRepository {
    void save(in ArcherRbacPolicy policy);
    ArcherRbacPolicy[] list();
    ArcherRbacPolicy* findById(string id);
    void remove(string id);
}
