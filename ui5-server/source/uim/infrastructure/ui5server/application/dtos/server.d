module uim.infrastructure.ui5server.application.dtos.server;

struct CreateServerDTO {
    string name;
    ushort port = 8080;
    string host = "0.0.0.0";
    string protocol = "http";
    bool acceptRemoteConnections = false;
    bool changePortIfInUse = false;
    bool simpleIndex = false;
    string sslCertPath;
    string sslKeyPath;
    string[] middlewareNames;
}

struct UpdateServerStatusDTO {
    string status;
}

struct ServerResponseDTO {
    string id;
    string name;
    ushort port;
    string host;
    string protocol;
    bool acceptRemoteConnections;
    bool changePortIfInUse;
    bool simpleIndex;
    string status;
    string sslCertPath;
    string sslKeyPath;
    string[] middlewareNames;
}
