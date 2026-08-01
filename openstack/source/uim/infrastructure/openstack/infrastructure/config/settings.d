module uim.infrastructure.openstack.infrastructure.config.settings;

import core.stdc.stdlib : getenv;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz, toStringz;

struct ServiceSettings {
    ushort port;
    string bindAddress;
    string openstackIdentityUrl;
    string openstackComputeUrl;
    string openstackToken;
    string defaultRegion;

    static ServiceSettings fromEnvironment() {
        return ServiceSettings(
            readPort(),
            readEnv("BIND_ADDRESS", "0.0.0.0"),
            readEnv("OPENSTACK_IDENTITY_URL", ""),
            readEnv("OPENSTACK_COMPUTE_URL", ""),
            readEnv("OPENSTACK_TOKEN", ""),
            readEnv("OPENSTACK_DEFAULT_REGION", "RegionOne")
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
