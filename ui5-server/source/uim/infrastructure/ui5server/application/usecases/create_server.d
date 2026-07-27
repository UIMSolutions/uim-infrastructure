/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.usecases.create_server;

import uim.infrastructure.ui5server.domain.ports.repositories.server : IServerRepository;
import uim.infrastructure.ui5server.domain.entities.server : Server, Protocol, ServerStatus;
import uim.infrastructure.ui5server.application.dtos.server : CreateServerDTO, ServerResponseDTO;

class CreateServerUseCase {
    private IServerRepository repo;

    this(IServerRepository repo) {
        this.repo = repo;
    }

    ServerResponseDTO execute(CreateServerDTO dto) {
        import std.conv : to;
        import std.uuid : randomUUID;

        auto server = Server(
            randomUUID().toString(),
            dto.name,
            dto.port,
            dto.host,
            dto.protocol.to!Protocol,
            dto.acceptRemoteConnections,
            dto.changePortIfInUse,
            dto.simpleIndex,
            ServerStatus.stopped,
            dto.sslCertPath,
            dto.sslKeyPath,
            dto.middlewareNames,
        );

        repo.save(server);

        return ServerResponseDTO(
            server.id,
            server.name,
            server.port,
            server.host,
            server.protocol.to!string,
            server.acceptRemoteConnections,
            server.changePortIfInUse,
            server.simpleIndex,
            server.status.to!string,
            server.sslCertPath,
            server.sslKeyPath,
            server.middlewareNames,
        );
    }
}
