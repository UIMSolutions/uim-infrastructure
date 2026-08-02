module app;

import uim.infrastructure.hts_service.application.usecases.create_unix_user :
    CreateUnixUserUseCase;
import uim.infrastructure.hts_service.application.usecases.generate_unix_hash :
    GenerateUnixHashUseCase;
import uim.infrastructure.hts_service.application.usecases.get_unix_user :
    GetUnixUserUseCase;
import uim.infrastructure.hts_service.application.usecases.ingest_dataset :
    IngestDatasetUseCase;
import uim.infrastructure.hts_service.application.usecases.list_by_reference :
    ListByReferenceUseCase;
import uim.infrastructure.hts_service.application.usecases.list_dataset_records :
    ListDatasetRecordsUseCase;
import uim.infrastructure.hts_service.application.usecases.list_datasets :
    ListDatasetsUseCase;
import uim.infrastructure.hts_service.application.usecases.list_unix_users :
    ListUnixUsersUseCase;
import uim.infrastructure.hts_service.application.usecases.set_unix_password :
    SetUnixPasswordUseCase;
import uim.infrastructure.hts_service.application.usecases.verify_unix_password :
    VerifyUnixPasswordUseCase;
import uim.infrastructure.hts_service.infrastructure.http.controllers.api_controller :
    ApiController;
import uim.infrastructure.hts_service.infrastructure.http.controllers.web_controller :
    WebController;
import uim.infrastructure.hts_service.infrastructure.parsers.hts_parser : BasicHtsParser;
import uim.infrastructure.hts_service.infrastructure.persistence.files.unix_auth_repository :
    FileUnixAuthRepository;
import uim.infrastructure.hts_service.infrastructure.persistence.memory.sequencing_repository :
    InMemorySequencingRepository;
import uim.infrastructure.hts_service.infrastructure.security.crypt_password_crypto :
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

    auto sequencingRepository = new InMemorySequencingRepository();
    auto unixRepository = new FileUnixAuthRepository(readPasswdPath(), readShadowPath());
    auto parser = new BasicHtsParser();
    auto crypto = new CryptPasswordCrypto();

    auto ingestDatasetUseCase = new IngestDatasetUseCase(sequencingRepository, parser);
    auto listDatasetRecordsUseCase = new ListDatasetRecordsUseCase(sequencingRepository);
    auto listByReferenceUseCase = new ListByReferenceUseCase(sequencingRepository);
    auto listDatasetsUseCase = new ListDatasetsUseCase(sequencingRepository);

    auto listUnixUsersUseCase = new ListUnixUsersUseCase(unixRepository);
    auto getUnixUserUseCase = new GetUnixUserUseCase(unixRepository);
    auto createUnixUserUseCase = new CreateUnixUserUseCase(unixRepository, crypto);
    auto setUnixPasswordUseCase = new SetUnixPasswordUseCase(unixRepository, crypto);
    auto generateUnixHashUseCase = new GenerateUnixHashUseCase(crypto);
    auto verifyUnixPasswordUseCase = new VerifyUnixPasswordUseCase(crypto);

    auto apiController = new ApiController(
        ingestDatasetUseCase,
        listDatasetRecordsUseCase,
        listByReferenceUseCase,
        listDatasetsUseCase,
        listUnixUsersUseCase,
        getUnixUserUseCase,
        createUnixUserUseCase,
        setUnixPasswordUseCase,
        generateUnixHashUseCase,
        verifyUnixPasswordUseCase
    );

    auto webController = new WebController(
        ingestDatasetUseCase,
        listDatasetRecordsUseCase,
        listByReferenceUseCase,
        listDatasetsUseCase,
        listUnixUsersUseCase,
        getUnixUserUseCase,
        createUnixUserUseCase,
        setUnixPasswordUseCase,
        generateUnixHashUseCase
    );

    auto router = new URLRouter;
    apiController.registerRoutes(router);
    webController.registerRoutes(router);

    logInfo("HTS service starting on %s:%d", settings.bindAddresses[0], settings.port);
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
