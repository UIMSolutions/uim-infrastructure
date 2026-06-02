module uim.infrastructure.archer.domain.entities.endpoint;

enum EndpointStatus {
    pending,
    available,
    rejected,
    deleting
}

struct EndpointTarget {
    string network;
    string subnet;
    string port;
}

struct ArcherEndpoint {
    string id;
    string serviceId;
    string name;
    string description;
    EndpointTarget target;
    string ipAddress;
    string[] tags;
    EndpointStatus status;
    bool connectionMirroring;
    string createdAt;
    string updatedAt;
    string projectId;
}

string endpointStatusToString(EndpointStatus status) {
    final switch (status) {
        case EndpointStatus.pending: return "PENDING";
        case EndpointStatus.available: return "AVAILABLE";
        case EndpointStatus.rejected: return "REJECTED";
        case EndpointStatus.deleting: return "PENDING_DELETE";
    }
}
