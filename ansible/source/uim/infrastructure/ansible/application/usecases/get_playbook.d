/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.application.usecases.get_playbook;

import uim.infrastructure.ansible.domain.entities.playbook : Playbook;
import uim.infrastructure.ansible.domain.ports.repositories.playbook : IPlaybookRepository;

class GetPlaybookUseCase {
    private IPlaybookRepository repository;

    this(IPlaybookRepository repository) {
        this.repository = repository;
    }

    Playbook* execute(string id) {
        if (id.length == 0)
            throw new Exception("playbook id must not be empty");
        return repository.findById(id);
    }
}
