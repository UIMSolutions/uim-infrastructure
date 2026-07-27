/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
