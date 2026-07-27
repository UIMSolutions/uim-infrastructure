/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.dtos.middleware;

struct RegisterMiddlewareDTO {
    string name;
    string type;
    uint order;
    bool enabled = true;
    string[string] config;
}

struct UpdateMiddlewareDTO {
    uint order;
    bool enabled;
}

struct MiddlewareResponseDTO {
    string name;
    string type;
    uint order;
    bool enabled;
    string[string] config;
}
