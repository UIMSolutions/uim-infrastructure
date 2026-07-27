/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.domain.ports.repositories.managed_resource;

import uim.infrastructure.crossplane.domain.entities.managed_resource : ManagedResource;

interface IManagedResourceRepository {
    void save(in ManagedResource resource);
    void remove(string id);
    ManagedResource[] list();
    ManagedResource* findById(string id);
    ManagedResource[] findByProviderId(string providerId);
    ManagedResource[] findByCompositeRef(string compositeRef);
}
