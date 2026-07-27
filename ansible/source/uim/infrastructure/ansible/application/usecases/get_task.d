/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.application.usecases.get_task;

import uim.infrastructure.ansible.domain.entities.task : Task;
import uim.infrastructure.ansible.domain.ports.repositories.task : ITaskRepository;

class GetTaskUseCase {
    private ITaskRepository repository;

    this(ITaskRepository repository) {
        this.repository = repository;
    }

    Task* execute(string id) {
        if (id.length == 0)
            throw new Exception("task id must not be empty");
        return repository.findById(id);
    }
}
