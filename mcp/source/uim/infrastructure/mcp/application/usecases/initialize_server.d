/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mcp.application.usecases.initialize_server;

import uim.infrastructure.mcp.application.dto.server_info : ServerInfo;

class InitializeServerUseCase {
    private string serverName;
    private string serverVersion;

    this(string serverName, string serverVersion) {
        this.serverName = serverName;
        this.serverVersion = serverVersion;
    }

    ServerInfo execute() {
        return ServerInfo(serverName, serverVersion);
    }
}
