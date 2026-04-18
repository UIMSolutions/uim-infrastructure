module uim.infrastructure.crossplane.domain.entities.provider;

enum ProviderType {
    AWS,
    GCP,
    AZURE,
    KUBERNETES,
    HELM,
    TERRAFORM,
    CUSTOM
}

enum ProviderStatus {
    HEALTHY,
    UNHEALTHY,
    UNKNOWN,
    INSTALLING,
    CONFIGURING
}

struct ProviderCredential {
    string key;
    string secretRef;
}

struct Provider {
    string id;
    string name;
    ProviderType providerType;
    string packageRef;
    ProviderStatus status;
    string region;
    ProviderCredential[] credentials;
    string[string] config;
    string createdAt;
}

unittest {
    auto p = Provider("p1", "aws-provider", ProviderType.AWS, "crossplane/provider-aws:v0.30",
        ProviderStatus.HEALTHY, "us-east-1", [], null, "2026-04-19T10:00:00Z");
    assert(p.name == "aws-provider");
    assert(p.providerType == ProviderType.AWS);
    assert(p.status == ProviderStatus.HEALTHY);
}
