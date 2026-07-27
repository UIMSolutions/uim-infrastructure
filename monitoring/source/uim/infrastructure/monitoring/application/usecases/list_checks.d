/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module monitoring_service.application.usecases.list_checks;

import monitoring_service.domain.entities.check : Check;
import monitoring_service.domain.ports.repositories.check : ICheckRepository;

class ListChecksUseCase {
    private ICheckRepository repository;

    this(ICheckRepository repository) {
        this.repository = repository;
    }

    Check[] execute() {
        return repository.list();
    }
}
