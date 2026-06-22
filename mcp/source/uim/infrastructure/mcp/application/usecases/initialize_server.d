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
