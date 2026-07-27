/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.manila.application.usecases.list_share_types;

import uim.infrastructure.manila.domain.entities.share_type : ShareType;
import uim.infrastructure.manila.domain.ports.repositories.share_type : IShareTypeRepository;

class ListShareTypesUseCase {
    private IShareTypeRepository repository;

    this(IShareTypeRepository repository) {
        this.repository = repository;
    }

    ShareType[] execute() {
        return repository.list();
    }
}