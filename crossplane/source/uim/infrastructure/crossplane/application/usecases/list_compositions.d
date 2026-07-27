/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.application.usecases.list_compositions;

import uim.infrastructure.crossplane.domain.entities.composition : Composition;
import uim.infrastructure.crossplane.domain.ports.repositories.composition : ICompositionRepository;

class ListCompositionsUseCase {
    private ICompositionRepository repo;

    this(ICompositionRepository repo) { this.repo = repo; }

    Composition[] execute() { return repo.list(); }
}
