/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.application.usecases.get_provider;

import uim.infrastructure.crossplane.domain.entities.provider : Provider;
import uim.infrastructure.crossplane.domain.ports.repositories.provider : IProviderRepository;

class GetProviderUseCase {
    private IProviderRepository repo;

    this(IProviderRepository repo) { this.repo = repo; }

    Provider* execute(string id) { return repo.findById(id); }
}
