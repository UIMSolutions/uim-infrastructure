/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.domain.ports.repositories.claim;

import uim.infrastructure.crossplane.domain.entities.claim : Claim;

interface IClaimRepository {
    void save(in Claim claim);
    void remove(string id);
    Claim[] list();
    Claim* findById(string id);
    Claim[] findByNamespace(string namespace);
}
