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
