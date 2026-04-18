module uim.infrastructure.crossplane.application.dto.commands;

struct CredentialDef {
    string key;
    string secretRef;
}

struct CreateProviderCommand {
    string name;
    string providerType;
    string packageRef;
    string region;
    CredentialDef[] credentials;
    string[string] config;
}

struct ComposedTemplateDef {
    string name;
    string kind;
    string apiGroup;
    string[string] patches;
    string[string] base;
}

struct CreateCompositionCommand {
    string name;
    string compositeTypeRef;
    ComposedTemplateDef[] resources;
    string[string] writeConnectionSecretsToRef;
}

struct CreateManagedResourceCommand {
    string name;
    string providerId;
    string apiGroup;
    string kind;
    string[string] spec;
}

struct CreateClaimCommand {
    string name;
    string namespace;
    string compositionRef;
    string[string] parameters;
}

struct ReconcileClaimCommand {
    string claimId;
}
