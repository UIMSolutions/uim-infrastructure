/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.application.usecases.agent_usecases;

import uim.infrastructure.archer.domain.entities.agent : ArcherAgent;
import uim.infrastructure.archer.domain.ports.repositories.agent : IAgentRepository;

class ListAgentsUseCase {
    private IAgentRepository repository;

    this(IAgentRepository repository) {
        this.repository = repository;
    }

    ArcherAgent[] execute() {
        return repository.list();
    }
}

class GetAgentUseCase {
    private IAgentRepository repository;

    this(IAgentRepository repository) {
        this.repository = repository;
    }

    ArcherAgent* execute(string host) {
        return repository.findByHost(host);
    }
}
