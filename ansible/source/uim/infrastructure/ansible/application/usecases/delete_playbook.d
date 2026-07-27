/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.application.usecases.delete_playbook;

import uim.infrastructure.ansible.domain.ports.repositories.playbook : IPlaybookRepository;

class DeletePlaybookUseCase {
    private IPlaybookRepository repository;

    this(IPlaybookRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        if (id.length == 0)
            throw new Exception("playbook id must not be empty");
        repository.remove(id);
    }
}
