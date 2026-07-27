/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
