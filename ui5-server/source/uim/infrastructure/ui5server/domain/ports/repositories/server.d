/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.domain.ports.repositories.server;

import uim.infrastructure.ui5server.domain.entities.server : Server;

interface IServerRepository {
    bool save(Server server);
    Server* findById(string id);
    Server* findByName(string name);
    Server[] findAll();
    bool remove(string id);
    bool updateStatus(string id, uim.infrastructure.ui5server.domain.entities.server.ServerStatus status);
}
