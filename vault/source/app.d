/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.infrastructure.vault.application.usecases.create_secret : CreateSecretUseCase;
import uim.infrastructure.vault.application.usecases.get_secret : GetSecretUseCase;
import uim.infrastructure.vault.application.usecases.issue_certificate : IssueCertificateUseCase;
import uim.infrastructure.vault.application.usecases.list_secrets : ListSecretsUseCase;
import uim.infrastructure.vault.application.usecases.revoke_certificate : RevokeCertificateUseCase;
import uim.infrastructure.vault.infrastructure.http.controllers.vault : VaultController;
import uim.infrastructure.vault.infrastructure.persistence.memory.secret_repository : InMemorySecretRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz, toStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemorySecretRepository(readDefaultTtlSeconds());

    auto controller = new VaultController(
        readEnv("VAULT_SERVER_NAME", "uim-vault-service"),
        readEnv("VAULT_SERVER_VERSION", "0.1.0"),
        new ListSecretsUseCase(repository),
        new GetSecretUseCase(repository),
        new CreateSecretUseCase(repository),
        new IssueCertificateUseCase(repository),
        new RevokeCertificateUseCase(repository)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Vault service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
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

private uint readDefaultTtlSeconds() {
    auto raw = getenv("VAULT_DEFAULT_TTL_SECONDS");
    if (raw is null) {
        return 3600;
    }

    uint parsed;
    auto err = collectException(parsed = fromStringz(raw).to!uint);
    return err is null ? parsed : 3600;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}

private string readEnv(string key, string fallback) {
    auto raw = getenv(key.toStringz());
    return raw is null ? fallback.idup : fromStringz(raw).idup;
}
