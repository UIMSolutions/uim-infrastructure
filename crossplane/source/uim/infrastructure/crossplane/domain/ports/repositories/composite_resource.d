/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.domain.ports.repositories.composite_resource;

import uim.infrastructure.crossplane.domain.entities.composite_resource : CompositeResource;

interface ICompositeResourceRepository {
    void save(in CompositeResource resource);
    void remove(string id);
    CompositeResource[] list();
    CompositeResource* findById(string id);
    CompositeResource[] findByCompositionId(string compositionId);
}
