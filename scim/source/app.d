module app;

import core.stdc.stdlib : getenv;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz, split, strip, toLower, toStringz;
import uim.infrastructure.scim.application.usecases.create_group : CreateGroupUseCase;
import uim.infrastructure.scim.application.usecases.create_user : CreateUserUseCase;
import uim.infrastructure.scim.application.usecases.delete_group : DeleteGroupUseCase;
import uim.infrastructure.scim.application.usecases.delete_user : DeleteUserUseCase;
import uim.infrastructure.scim.application.usecases.get_group : GetGroupUseCase;
import uim.infrastructure.scim.application.usecases.get_user : GetUserUseCase;
import uim.infrastructure.scim.application.usecases.list_groups : ListGroupsUseCase;
import uim.infrastructure.scim.application.usecases.list_users : ListUsersUseCase;
import uim.infrastructure.scim.application.usecases.replace_group : ReplaceGroupUseCase;
import uim.infrastructure.scim.application.usecases.replace_user : ReplaceUserUseCase;
import uim.infrastructure.scim.domain.ports.repositories.group : IGroupRepository;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;
import uim.infrastructure.scim.infrastructure.auth.static_bearer_token_validator : StaticBearerTokenValidator;
import uim.infrastructure.scim.infrastructure.auth.token_validator : ITokenValidator;
import uim.infrastructure.scim.infrastructure.http.controllers.scim : ScimController;
import uim.infrastructure.scim.infrastructure.persistence.memory.group_repository : InMemoryGroupRepository;
import uim.infrastructure.scim.infrastructure.persistence.memory.user_repository : InMemoryUserRepository;
import uim.infrastructure.scim.infrastructure.persistence.postgresql.group_repository : PostgreSqlGroupRepository;
import uim.infrastructure.scim.infrastructure.persistence.postgresql.user_repository : PostgreSqlUserRepository;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto backend = readStorageBackend();
    auto postgresDsn = readPostgresDsn();

    IUserRepository userRepository;
    IGroupRepository groupRepository;
    if (backend == "postgres") {
        userRepository = new PostgreSqlUserRepository(postgresDsn);
        groupRepository = new PostgreSqlGroupRepository(postgresDsn);
    } else {
        userRepository = new InMemoryUserRepository();
        groupRepository = new InMemoryGroupRepository();
    }

    auto tokenValidator = buildTokenValidator();

    auto controller = new ScimController(
        new ListUsersUseCase(userRepository),
        new CreateUserUseCase(userRepository),
        new GetUserUseCase(userRepository),
        new ReplaceUserUseCase(userRepository),
        new DeleteUserUseCase(userRepository),
        new ListGroupsUseCase(groupRepository),
        new CreateGroupUseCase(groupRepository, userRepository),
        new GetGroupUseCase(groupRepository),
        new ReplaceGroupUseCase(groupRepository, userRepository),
        new DeleteGroupUseCase(groupRepository),
        readBaseUrl(),
        tokenValidator,
        readAllowAnonymousDiscovery()
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("SCIM service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ITokenValidator buildTokenValidator() {
    auto validator = new StaticBearerTokenValidator(readBoolEnv("ALLOW_INSECURE_TOKENS", false));
    registerStaticTokens(validator, readEnv("SCIM_TOKEN_MAP", ""));
    return validator;
}

private void registerStaticTokens(StaticBearerTokenValidator validator, string rawMap) {
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
        auto subject = spec.length > 0 ? spec[0].strip() : "";
        string[] roles = spec.length > 1 ? parseRoles(spec[1]) : ["member"];
        if (subject.length > 0) {
            validator.register(token, subject, roles);
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

private string readBaseUrl() {
    auto raw = getenv("SCIM_BASE_URL");
    if (raw is null) {
        return "http://localhost:8080/scim/v2".idup;
    }
    return fromStringz(raw).idup;
}

private string readStorageBackend() {
    return readEnv("STORAGE_BACKEND", "memory").toLower();
}

private string readPostgresDsn() {
    return readEnv("POSTGRES_DSN", "postgresql://postgres:postgres@localhost:5432/scim");
}

private bool readAllowAnonymousDiscovery() {
    return readBoolEnv("SCIM_ALLOW_ANONYMOUS_DISCOVERY", false);
}

private string readEnv(string key, string fallback) {
    auto raw = getenv(key.toStringz());
    return raw is null ? fallback.idup : fromStringz(raw).idup;
}

private bool readBoolEnv(string key, bool fallback) {
    auto value = readEnv(key, fallback ? "true" : "false").toLower();
    return value == "1" || value == "true" || value == "yes" || value == "on";
}
