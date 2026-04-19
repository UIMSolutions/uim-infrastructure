module uim.infrastructure.kafka.application.dtos.broker;

struct RegisterBrokerDTO {
    uint id;
    string host;
    ushort port;
    string rack;
}

struct UpdateBrokerDTO {
    string status;
}

struct BrokerResponseDTO {
    uint id;
    string host;
    ushort port;
    string status;
    string rack;
    string startedAt;
}
