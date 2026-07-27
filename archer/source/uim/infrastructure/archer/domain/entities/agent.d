/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.domain.entities.agent;

enum AgentProvider {
    tenant,
    cp
}

struct ArcherAgent {
    string host;
    string availabilityZone;
    AgentProvider provider;
    bool enabled;
    string physnet;
    string createdAt;
    string updatedAt;
    string heartbeatAt;
    int services;
}

string agentProviderToString(AgentProvider provider) {
    return provider == AgentProvider.cp ? "cp" : "tenant";
}
