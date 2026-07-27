/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.usecases.list_middleware;

import uim.infrastructure.ui5server.domain.ports.repositories.middleware : IMiddlewareRepository;
import uim.infrastructure.ui5server.application.dtos.middleware : MiddlewareResponseDTO;

class ListMiddlewareUseCase {
    private IMiddlewareRepository repo;

    this(IMiddlewareRepository repo) {
        this.repo = repo;
    }

    MiddlewareResponseDTO[] execute() {
        import std.conv : to;
        MiddlewareResponseDTO[] results;
        foreach (mw; repo.findAllOrdered()) {
            results ~= MiddlewareResponseDTO(
                mw.name,
                mw.type.to!string,
                mw.order,
                mw.enabled,
                mw.config,
            );
        }
        return results;
    }
}
