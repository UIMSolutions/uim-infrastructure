/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.infrastructure.manila.application.usecases.create_share : CreateShareUseCase;
import uim.infrastructure.manila.application.usecases.create_snapshot : CreateSnapshotUseCase;
import uim.infrastructure.manila.application.usecases.delete_share : DeleteShareUseCase;
import uim.infrastructure.manila.application.usecases.get_quota_set : GetQuotaSetUseCase;
import uim.infrastructure.manila.application.usecases.get_share : GetShareUseCase;
import uim.infrastructure.manila.application.usecases.list_share_types : ListShareTypesUseCase;
import uim.infrastructure.manila.application.usecases.list_shares : ListSharesUseCase;
import uim.infrastructure.manila.application.usecases.list_snapshots : ListSnapshotsUseCase;
import uim.infrastructure.manila.infrastructure.auth.keystone_http_validator : KeystoneHttpTokenValidator;
import uim.infrastructure.manila.infrastructure.auth.static_token_validator : StaticTokenValidator;
import uim.infrastructure.manila.infrastructure.auth.token_validator : ITokenValidator;
import uim.infrastructure.manila.infrastructure.http.controllers.manila : ManilaController;
import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;
import uim.infrastructure.manila.domain.ports.repositories.share_type : IShareTypeRepository;
import uim.infrastructure.manila.domain.ports.repositories.snapshot : ISnapshotRepository;
import uim.infrastructure.manila.infrastructure.persistence.memory.share_repository : InMemoryShareRepository;
import uim.infrastructure.manila.infrastructure.persistence.memory.share_type_repository : InMemoryShareTypeRepository;
import uim.infrastructure.manila.infrastructure.persistence.memory.snapshot_repository : InMemorySnapshotRepository;
import uim.infrastructure.manila.infrastructure.persistence.postgresql.share_repository : PostgreSqlShareRepository;
import uim.infrastructure.manila.infrastructure.persistence.postgresql.share_type_repository : PostgreSqlShareTypeRepository;
import uim.infrastructure.manila.infrastructure.persistence.postgresql.snapshot_repository : PostgreSqlSnapshotRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz, split, strip, toLower, toStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    ITokenValidator tokenValidator = buildTokenValidator();

    auto backend = readStorageBackend();
    auto pgDsn = readPostgresDsn();

    IShareRepository shareRepository;
    IShareTypeRepository shareTypeRepository;
    ISnapshotRepository snapshotRepository;

    if (backend == "postgres") {
        shareRepository = new PostgreSqlShareRepository(pgDsn);
        shareTypeRepository = new PostgreSqlShareTypeRepository(pgDsn);
        snapshotRepository = new PostgreSqlSnapshotRepository(pgDsn);
    } else {
        shareRepository = new InMemoryShareRepository();
        shareTypeRepository = new InMemoryShareTypeRepository();
        snapshotRepository = new InMemorySnapshotRepository();
    }

    auto controller = new ManilaController(
        new ListShareTypesUseCase(shareTypeRepository),
        new ListSharesUseCase(shareRepository),
        new CreateShareUseCase(shareRepository, shareTypeRepository),
        new GetShareUseCase(shareRepository),
        new DeleteShareUseCase(shareRepository, snapshotRepository),
        new ListSnapshotsUseCase(snapshotRepository),
        new CreateSnapshotUseCase(snapshotRepository, shareRepository),
        new GetQuotaSetUseCase(shareRepository, snapshotRepository),
        tokenValidator,
        readMicroversionDefault(),
        readMicroversionMin(),
        readMicroversionMax()
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Manila service starting on %s:%d (backend=%s)", settings.bindAddresses[0], settings.port, backend);
    listenHTTP(settings, router);
    runApplication();
}

private ITokenValidator buildTokenValidator() {
    auto keystoneUrl = readEnv("KEYSTONE_URL", "");
    auto keystoneAdminToken = readEnv("KEYSTONE_ADMIN_TOKEN", "");
    auto allowInsecureFallback = readBoolEnv("ALLOW_INSECURE_TOKENS", false);

    auto staticValidator = new StaticTokenValidator(allowInsecureFallback);
    registerStaticTokens(staticValidator, readEnv("KEYSTONE_TOKEN_MAP", ""));

    if (keystoneUrl.length == 0 || keystoneAdminToken.length == 0) {
        return staticValidator;
    }

    return new KeystoneHttpTokenValidator(keystoneUrl, keystoneAdminToken, staticValidator);
}

private void registerStaticTokens(StaticTokenValidator validator, string rawMap) {
    if (rawMap.length == 0) {
        return;
    }

    foreach (entry; split(rawMap, ";")) {
        auto trimmed = entry.strip();
        if (trimmed.length == 0) {
            continue;
        }

        auto parts = split(trimmed, "=");
        if (parts.length != 2) {
            continue;
        }

        auto token = parts[0].strip();
        auto body = parts[1].strip();
        if (token.length == 0 || body.length == 0) {
            continue;
        }

        auto spec = split(body, ":");
        auto projectId = spec.length > 0 ? spec[0].strip() : "";
        auto userId = spec.length > 1 ? spec[1].strip() : "user-" ~ projectId;
        string[] roles = spec.length > 2 ? parseRoles(spec[2]) : ["member"];
        if (projectId.length > 0) {
            validator.register(token, projectId, userId, roles);
        }
    }
}

private string[] parseRoles(string rawRoles) {
    string[] roles;
    foreach (role; split(rawRoles, "|")) {
        auto trimmed = role.strip().toLower();
        if (trimmed.length > 0) {
            roles ~= trimmed;
        }
    }
    if (roles.length == 0) {
        roles = ["member"];
    }
    return roles;
}

private string readStorageBackend() {
    return readEnv("STORAGE_BACKEND", "memory").toLower();
}

private string readPostgresDsn() {
    return readEnv("POSTGRES_DSN", "postgresql://postgres:postgres@localhost:5432/manila");
}

private string readMicroversionDefault() {
    return readEnv("MANILA_MICROVERSION_DEFAULT", "2.93");
}

private string readMicroversionMin() {
    return readEnv("MANILA_MICROVERSION_MIN", "2.1");
}

private string readMicroversionMax() {
    return readEnv("MANILA_MICROVERSION_MAX", "2.93");
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

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}

private string readEnv(string key, string fallback) {
    auto raw = getenv(key.toStringz());
    return raw is null ? fallback.idup : fromStringz(raw).idup;
}

private bool readBoolEnv(string key, bool fallback) {
    auto value = readEnv(key, fallback ? "true" : "false").toLower();
    return value == "1" || value == "true" || value == "yes" || value == "on";
}