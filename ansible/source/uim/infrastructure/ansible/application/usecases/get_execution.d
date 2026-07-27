/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.application.usecases.get_execution;

import uim.infrastructure.ansible.domain.entities.execution : Execution;
import uim.infrastructure.ansible.domain.ports.repositories.execution : IExecutionRepository;

class GetExecutionUseCase {
    private IExecutionRepository repository;

    this(IExecutionRepository repository) {
        this.repository = repository;
    }

    Execution* execute(string id) {
        if (id.length == 0)
            throw new Exception("execution id must not be empty");
        return repository.findById(id);
    }
}
