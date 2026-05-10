module uim.infrastructure.ui5server.application.usecases.update_server_status;

import uim.infrastructure.ui5server.domain.ports.repositories.server : IServerRepository;
import uim.infrastructure.ui5server.domain.entities.server : ServerStatus;

class UpdateServerStatusUseCase {
    private IServerRepository repo;

    this(IServerRepository repo) {
        this.repo = repo;
    }

    bool execute(string id, string status) {
        import std.conv : to;
        try {
            auto s = status.to!ServerStatus;
            return repo.updateStatus(id, s);
        } catch (Exception e) {
            return false;
        }
    }
}
