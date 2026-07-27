/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.application.usecases.list_managed_resources;

import uim.infrastructure.crossplane.domain.entities.managed_resource : ManagedResource;
import uim.infrastructure.crossplane.domain.ports.repositories.managed_resource : IManagedResourceRepository;

class ListManagedResourcesUseCase {
    private IManagedResourceRepository repo;

    this(IManagedResourceRepository repo) { this.repo = repo; }

    ManagedResource[] execute() { return repo.list(); }
}
