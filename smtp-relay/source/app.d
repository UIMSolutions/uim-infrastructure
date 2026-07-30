module app;

import uim.infrastructure.smtp_relay.application.usecases.get_message : GetMessageUseCase;
import uim.infrastructure.smtp_relay.application.usecases.list_messages : ListMessagesUseCase;
import uim.infrastructure.smtp_relay.application.usecases.relay_message : RelayMessageUseCase;
import uim.infrastructure.smtp_relay.domain.ports.repositories.email_message_repository : IEmailMessageRepository;
import uim.infrastructure.smtp_relay.infrastructure.http.controllers.api_controller : ApiController;
import uim.infrastructure.smtp_relay.infrastructure.http.controllers.web_controller : WebController;
import uim.infrastructure.smtp_relay.infrastructure.persistence.file.email_message_repository :
    FileEmailMessageRepository;
import uim.infrastructure.smtp_relay.infrastructure.persistence.memory.email_message_repository :
    InMemoryEmailMessageRepository;
import uim.infrastructure.smtp_relay.infrastructure.smtp.smtp_relay_adapter : SmtpRelayAdapter;
import std.conv : to;
import std.exception : collectException;
import std.file : write;
import std.string : fromStringz, toLower;
import core.stdc.stdlib : getenv;
import core.sys.posix.unistd : getpid;
import vibe.vibe;

void main() {
    writePidFile();

    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    IEmailMessageRepository repository;
    if (readStoreBackend() == "memory") {
        repository = new InMemoryEmailMessageRepository();
    } else {
        repository = new FileEmailMessageRepository(readMessageStorePath());
    }

    auto smtpRelay = new SmtpRelayAdapter(
        readSmtpHost(),
        readSmtpPort(),
        "uim-smtp-relay",
        readSmtpSecurity(),
        readSmtpAuth(),
        readSmtpUsername(),
        readSmtpPassword()
    );

    auto relayUseCase = new RelayMessageUseCase(repository, smtpRelay, readDefaultSender());
    auto listUseCase = new ListMessagesUseCase(repository);
    auto getUseCase = new GetMessageUseCase(repository);

    auto apiController = new ApiController(relayUseCase, listUseCase, getUseCase);
    auto webController = new WebController(relayUseCase, listUseCase, getUseCase);

    auto router = new URLRouter;
    apiController.registerRoutes(router);
    webController.registerRoutes(router);

    logInfo("SMTP relay service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private void writePidFile() {
    auto raw = getenv("PID_FILE");
    string path = raw is null ? "/var/run/uim-smtp-relay-service.pid" : fromStringz(raw).idup;
    try {
        write(path, to!string(getpid()));
    } catch (Exception) {
        // PID file write is best-effort.
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

private ushort readSmtpPort() {
    auto raw = getenv("SMTP_PORT");
    if (raw is null) {
        return 1025;
    }

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 1025;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}

private string readSmtpHost() {
    auto raw = getenv("SMTP_HOST");
    return raw is null ? "mailhog".idup : fromStringz(raw).idup;
}

private string readDefaultSender() {
    auto raw = getenv("SMTP_FROM");
    return raw is null ? "noreply@uim.local".idup : fromStringz(raw).idup;
}

private string readSmtpSecurity() {
    auto raw = getenv("SMTP_SECURITY");
    return raw is null ? "plain".idup : fromStringz(raw).toLower.idup;
}

private string readSmtpAuth() {
    auto raw = getenv("SMTP_AUTH");
    return raw is null ? "none".idup : fromStringz(raw).toLower.idup;
}

private string readSmtpUsername() {
    auto raw = getenv("SMTP_USERNAME");
    return raw is null ? "".idup : fromStringz(raw).idup;
}

private string readSmtpPassword() {
    auto raw = getenv("SMTP_PASSWORD");
    return raw is null ? "".idup : fromStringz(raw).idup;
}

private string readStoreBackend() {
    auto raw = getenv("STORE_BACKEND");
    return raw is null ? "file".idup : fromStringz(raw).toLower.idup;
}

private string readMessageStorePath() {
    auto raw = getenv("MESSAGE_STORE_PATH");
    return raw is null ? "/tmp/uim-smtp-relay-messages.json".idup : fromStringz(raw).idup;
}
