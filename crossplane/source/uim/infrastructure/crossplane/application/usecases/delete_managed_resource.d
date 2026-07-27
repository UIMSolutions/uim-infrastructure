/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.application.usecases.delete_managed_resource;

import uim.infrastructure.crossplane.domain.ports.repositories.managed_resource : IManagedResourceRepository;

class DeleteManagedResourceUseCase {
    private IManagedResourceRepository repo;

    this(IManagedResourceRepository repo) { this.repo = repo; }

    void execute(string id) { repo.remove(id); }
}
