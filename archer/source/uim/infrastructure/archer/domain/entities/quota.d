module uim.infrastructure.archer.domain.entities.quota;

struct ArcherQuota {
    int service;
    int endpoint;
    int inUseService;
    int inUseEndpoint;
    string projectId;
}

struct ArcherQuotaDefaults {
    int service;
    int endpoint;
}
