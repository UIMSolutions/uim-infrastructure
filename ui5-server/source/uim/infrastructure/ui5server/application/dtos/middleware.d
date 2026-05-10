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
