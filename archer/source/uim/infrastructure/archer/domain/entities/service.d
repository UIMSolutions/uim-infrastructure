/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.domain.entities.service;

import std.string : toLower;

enum ServiceStatus {
    pending,
    available,
    error,
    deleting
}

enum ServiceVisibility {
    private_,
    public_
}

enum ServiceProvider {
    tenant,
    cp
}

enum ServiceProtocol {
    http,
    tcp
}

struct ArcherService {
    string id;
    bool enabled;
    string name;
    string description;
    ushort[] ports;
    string networkId;
    string[] ipAddresses;
    ServiceStatus status;
    bool requireApproval;
    ServiceVisibility visibility;
    string availabilityZone;
    string host;
    bool proxyProtocol;
    string[] tags;
    ServiceProvider provider;
    ServiceProtocol protocol;
    string createdAt;
    string updatedAt;
    string projectId;
    string healthStatus;
}

ServiceVisibility parseServiceVisibility(string raw) {
    auto normalized = raw.toLower();
    if (normalized == "public") return ServiceVisibility.public_;
    return ServiceVisibility.private_;
}

ServiceProvider parseServiceProvider(string raw) {
    auto normalized = raw.toLower();
    if (normalized == "cp") return ServiceProvider.cp;
    return ServiceProvider.tenant;
}

ServiceProtocol parseServiceProtocol(string raw) {
    auto normalized = raw.toLower();
    if (normalized == "tcp") return ServiceProtocol.tcp;
    return ServiceProtocol.http;
}

string visibilityToString(ServiceVisibility visibility) {
    return visibility == ServiceVisibility.public_ ? "public" : "private";
}

string providerToString(ServiceProvider provider) {
    return provider == ServiceProvider.cp ? "cp" : "tenant";
}

string protocolToString(ServiceProtocol protocol) {
    return protocol == ServiceProtocol.tcp ? "TCP" : "HTTP";
}

string serviceStatusToString(ServiceStatus status) {
    final switch (status) {
        case ServiceStatus.pending: return "PENDING";
        case ServiceStatus.available: return "AVAILABLE";
        case ServiceStatus.error: return "ERROR";
        case ServiceStatus.deleting: return "PENDING_DELETE";
    }
}
