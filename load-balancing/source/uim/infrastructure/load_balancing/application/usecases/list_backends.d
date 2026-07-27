/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module lb_service.application.usecases.list_backends;

import lb_service.domain.entities.backend : Backend;
import lb_service.domain.ports.repositories.backend : IBackendRepository;

class ListBackendsUseCase {
    private IBackendRepository repository;

    this(IBackendRepository repository) {
        this.repository = repository;
    }

    Backend[] execute() {
        return repository.list();
    }
}
