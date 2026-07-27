/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
