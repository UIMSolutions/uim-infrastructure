/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.application.usecases.get_composition;

import uim.infrastructure.crossplane.domain.entities.composition : Composition;
import uim.infrastructure.crossplane.domain.ports.repositories.composition : ICompositionRepository;

class GetCompositionUseCase {
    private ICompositionRepository repo;

    this(ICompositionRepository repo) { this.repo = repo; }

    Composition* execute(string id) { return repo.findById(id); }
}
