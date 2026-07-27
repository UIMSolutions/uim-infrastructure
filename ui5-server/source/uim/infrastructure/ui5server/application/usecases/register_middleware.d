/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.usecases.register_middleware;

import uim.infrastructure.ui5server.domain.ports.repositories.middleware : IMiddlewareRepository;
import uim.infrastructure.ui5server.domain.entities.middleware : Middleware, MiddlewareType;
import uim.infrastructure.ui5server.application.dtos.middleware : RegisterMiddlewareDTO, MiddlewareResponseDTO;

class RegisterMiddlewareUseCase {
    private IMiddlewareRepository repo;

    this(IMiddlewareRepository repo) {
        this.repo = repo;
    }

    MiddlewareResponseDTO execute(RegisterMiddlewareDTO dto) {
        import std.conv : to;
        auto mw = Middleware(
            dto.name,
            dto.type.to!MiddlewareType,
            dto.order,
            dto.enabled,
            dto.config,
        );

        repo.save(mw);

        return MiddlewareResponseDTO(
            mw.name,
            mw.type.to!string,
            mw.order,
            mw.enabled,
            mw.config,
        );
    }
}
