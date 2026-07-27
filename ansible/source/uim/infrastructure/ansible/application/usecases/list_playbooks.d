/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.application.usecases.list_playbooks;

import uim.infrastructure.ansible.domain.entities.playbook : Playbook;
import uim.infrastructure.ansible.domain.ports.repositories.playbook : IPlaybookRepository;

class ListPlaybooksUseCase {
    private IPlaybookRepository repository;

    this(IPlaybookRepository repository) {
        this.repository = repository;
    }

    Playbook[] execute() {
        return repository.list();
    }
}
