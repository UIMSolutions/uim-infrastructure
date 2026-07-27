/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.application.usecases.list_tasks;

import uim.infrastructure.ansible.domain.entities.task : Task;
import uim.infrastructure.ansible.domain.ports.repositories.task : ITaskRepository;

class ListTasksUseCase {
    private ITaskRepository repository;

    this(ITaskRepository repository) {
        this.repository = repository;
    }

    Task[] execute() {
        return repository.list();
    }
}
