module uim.infrastructure.ui5server.application.usecases.get_server;

import uim.infrastructure.ui5server.domain.ports.repositories.server : IServerRepository;
import uim.infrastructure.ui5server.application.dtos.server : ServerResponseDTO;

class GetServerUseCase {
    private IServerRepository repo;

    this(IServerRepository repo) {
        this.repo = repo;
    }

    ServerResponseDTO* execute(string id) {
        import std.conv : to;
        auto s = repo.findById(id);
        if (s is null) return null;

        auto result = new ServerResponseDTO(
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
        return result;
    }
}
