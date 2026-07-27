/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.application.usecases.list_composite_resources;

import uim.infrastructure.crossplane.domain.entities.composite_resource : CompositeResource;
import uim.infrastructure.crossplane.domain.ports.repositories.composite_resource : ICompositeResourceRepository;

class ListCompositeResourcesUseCase {
    private ICompositeResourceRepository repo;

    this(ICompositeResourceRepository repo) { this.repo = repo; }

    CompositeResource[] execute() { return repo.list(); }
}
