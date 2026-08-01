module uim.infrastructure.sdk_ai.infrastructure.config.settings;

import core.stdc.stdlib : getenv;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz, toStringz;

struct ServiceSettings {
    ushort port;
    string bindAddress;
    string sdkProvider;
    string aiBaseUrl;
    string aiApiKey;
    string aiResourceGroup;
    string aiDeploymentId;
    string defaultTenantId;

    static ServiceSettings fromEnvironment() {
        return ServiceSettings(
            readPort(),
            readEnv("BIND_ADDRESS", "0.0.0.0"),
            readEnv("AI_PROVIDER", "sap-ai-core"),
            readEnv("AI_BASE_URL", ""),
            readEnv("AI_API_KEY", ""),
            readEnv("AI_RESOURCE_GROUP", "default"),
            readEnv("AI_DEPLOYMENT_ID", "default"),
            readEnv("DEFAULT_TENANT_ID", "default")
        );
    }
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) {
        return 8080;
    }

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 8080;
}

private string readEnv(string key, string fallback) {
    auto raw = getenv(key.toStringz());
    return raw is null ? fallback.idup : fromStringz(raw).idup;
}
