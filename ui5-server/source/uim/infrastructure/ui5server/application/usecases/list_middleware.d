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
