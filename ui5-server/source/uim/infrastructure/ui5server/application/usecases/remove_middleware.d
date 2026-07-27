/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.usecases.remove_middleware;

import uim.infrastructure.ui5server.domain.ports.repositories.middleware : IMiddlewareRepository;

class RemoveMiddlewareUseCase {
    private IMiddlewareRepository repo;

    this(IMiddlewareRepository repo) {
        this.repo = repo;
    }

    bool execute(string name) {
        return repo.remove(name);
    }
}
