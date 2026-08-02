module app;

import uim.infrastructure.unix_auth_service.application.usecases.create_user :
    CreateUserUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.generate_hash :
    GenerateHashUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.get_user : GetUserUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.list_users :
    ListUsersUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.set_password :
    SetPasswordUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.verify_password :
    VerifyPasswordUseCase;
import uim.infrastructure.unix_auth_service.infrastructure.http.controllers.api_controller :
    ApiController;
import uim.infrastructure.unix_auth_service.infrastructure.http.controllers.web_controller :
    WebController;
import uim.infrastructure.unix_auth_service.infrastructure.persistence.files.unix_auth_repository :
    FileUnixAuthRepository;
import uim.infrastructure.unix_auth_service.infrastructure.security.crypt_password_crypto :
    CryptPasswordCrypto;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new FileUnixAuthRepository(readPasswdPath(), readShadowPath());
    auto crypto = new CryptPasswordCrypto();

    auto listUsersUseCase = new ListUsersUseCase(repository);
    auto getUserUseCase = new GetUserUseCase(repository);
    auto createUserUseCase = new CreateUserUseCase(repository, crypto);
    auto setPasswordUseCase = new SetPasswordUseCase(repository, crypto);
    auto generateHashUseCase = new GenerateHashUseCase(crypto);
    auto verifyPasswordUseCase = new VerifyPasswordUseCase(crypto);

    auto apiController = new ApiController(
        listUsersUseCase,
        getUserUseCase,
        createUserUseCase,
        setPasswordUseCase,
        generateHashUseCase,
        verifyPasswordUseCase
    );

    auto webController = new WebController(
        listUsersUseCase,
        getUserUseCase,
        createUserUseCase,
        setPasswordUseCase,
        generateHashUseCase
    );

    auto router = new URLRouter;
    apiController.registerRoutes(router);
    webController.registerRoutes(router);

    logInfo("UNIX auth service starting on %s:%d", settings.bindAddresses[0], settings.port);
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

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}

private string readPasswdPath() {
    auto raw = getenv("PASSWD_FILE");
    return raw is null ? "/etc/passwd".idup : fromStringz(raw).idup;
}

private string readShadowPath() {
    auto raw = getenv("SHADOW_FILE");
    return raw is null ? "/etc/shadow".idup : fromStringz(raw).idup;
}
