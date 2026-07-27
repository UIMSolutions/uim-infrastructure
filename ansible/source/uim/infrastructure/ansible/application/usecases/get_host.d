/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.application.usecases.get_host;

import uim.infrastructure.ansible.domain.entities.host : Host;
import uim.infrastructure.ansible.domain.ports.repositories.host : IHostRepository;

class GetHostUseCase {
    private IHostRepository repository;

    this(IHostRepository repository) {
        this.repository = repository;
    }

    Host* execute(string id) {
        if (id.length == 0)
            throw new Exception("host id must not be empty");
        return repository.findById(id);
    }
}
