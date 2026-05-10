module uim.infrastructure.ui5server.application.usecases.list_servers;

import uim.infrastructure.ui5server.domain.ports.repositories.server : IServerRepository;
import uim.infrastructure.ui5server.application.dtos.server : ServerResponseDTO;

class ListServersUseCase {
    private IServerRepository repo;

    this(IServerRepository repo) {
        this.repo = repo;
    }

    ServerResponseDTO[] execute() {
        import std.conv : to;
        ServerResponseDTO[] results;
        foreach (s; repo.findAll()) {
            results ~= ServerResponseDTO(
                s.id,
                s.name,
                s.port,
                s.host,
                s.protocol.to!string,
                s.acceptRemoteConnections,
                s.changePortIfInUse,
                s.simpleIndex,
                s.status.to!string,
                s.sslCertPath,
                s.sslKeyPath,
                s.middlewareNames,
            );
        }
        return results;
    }
}
