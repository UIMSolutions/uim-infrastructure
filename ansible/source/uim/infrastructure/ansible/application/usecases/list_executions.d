/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.application.usecases.list_executions;

import uim.infrastructure.ansible.domain.entities.execution : Execution;
import uim.infrastructure.ansible.domain.ports.repositories.execution : IExecutionRepository;

class ListExecutionsUseCase {
    private IExecutionRepository repository;

    this(IExecutionRepository repository) {
        this.repository = repository;
    }

    Execution[] execute() {
        return repository.list();
    }
}
