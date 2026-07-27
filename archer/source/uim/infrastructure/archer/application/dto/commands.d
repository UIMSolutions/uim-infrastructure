/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.application.dto.commands;

struct CreateServiceCommand {
    bool enabled;
    string name;
    string description;
    ushort[] ports;
    string networkId;
    string[] ipAddresses;
    bool requireApproval;
    string visibility;
    string availabilityZone;
    bool proxyProtocol;
    string[] tags;
    string provider;
    string protocol;
    string projectId;
}

struct UpdateServiceCommand {
    string serviceId;
    bool hasEnabled;
    bool enabled;
    bool hasName;
    string name;
    bool hasDescription;
    string description;
    bool hasPorts;
    ushort[] ports;
    bool hasIpAddresses;
    string[] ipAddresses;
    bool hasRequireApproval;
    bool requireApproval;
    bool hasVisibility;
    string visibility;
    bool hasProxyProtocol;
    bool proxyProtocol;
    bool hasTags;
    string[] tags;
    bool hasProtocol;
    string protocol;
}

struct MigrateServiceCommand {
    string serviceId;
    string targetHost;
}

struct EndpointTargetCommand {
    string network;
    string subnet;
    string port;
}

struct CreateEndpointCommand {
    string serviceId;
    string name;
    string description;
    EndpointTargetCommand target;
    string[] tags;
    bool connectionMirroring;
    string projectId;
}

struct UpdateEndpointCommand {
    string endpointId;
    bool hasName;
    string name;
    bool hasDescription;
    string description;
    bool hasTags;
    string[] tags;
    bool hasConnectionMirroring;
    bool connectionMirroring;
}

struct DecideEndpointsCommand {
    string serviceId;
    string[] endpointIds;
    string[] projectIds;
}

struct CreateRbacPolicyCommand {
    string serviceId;
    string target;
    string projectId;
}

struct UpdateRbacPolicyCommand {
    string policyId;
    bool hasTarget;
    string target;
    bool hasProjectId;
    string projectId;
}

struct UpdateQuotaCommand {
    string projectId;
    bool hasService;
    int service;
    bool hasEndpoint;
    int endpoint;
}
