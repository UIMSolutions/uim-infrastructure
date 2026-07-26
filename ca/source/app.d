module app;

import uim.infrastructure.ca.application.usecases.initialize_ca : InitializeCaUseCase;
import uim.infrastructure.ca.application.usecases.get_ca : GetCaUseCase;
import uim.infrastructure.ca.application.usecases.issue_certificate : IssueCertificateUseCase;
import uim.infrastructure.ca.application.usecases.list_certificates : ListCertificatesUseCase;
import uim.infrastructure.ca.application.usecases.get_certificate : GetCertificateUseCase;
import uim.infrastructure.ca.application.usecases.revoke_certificate : RevokeCertificateUseCase;
import uim.infrastructure.ca.infrastructure.http.controllers.ca : CaController;
import uim.infrastructure.ca.infrastructure.persistence.memory.ca_state_repository : InMemoryCaStateRepository;
import uim.infrastructure.ca.infrastructure.persistence.memory.certificate_repository : InMemoryCertificateRepository;
import uim.infrastructure.ca.infrastructure.crypto.openssl_ca_engine : OpenSslCaEngine;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto caRepository = new InMemoryCaStateRepository();
    auto certificateRepository = new InMemoryCertificateRepository();
    auto cryptoEngine = new OpenSslCaEngine();

    auto initializeCaUC = new InitializeCaUseCase(caRepository, cryptoEngine);
    auto getCaUC = new GetCaUseCase(caRepository);
    auto issueCertificateUC = new IssueCertificateUseCase(caRepository, certificateRepository, cryptoEngine);
    auto listCertificatesUC = new ListCertificatesUseCase(certificateRepository);
    auto getCertificateUC = new GetCertificateUseCase(certificateRepository);
    auto revokeCertificateUC = new RevokeCertificateUseCase(certificateRepository);

    auto controller = new CaController(
        initializeCaUC,
        getCaUC,
        issueCertificateUC,
        listCertificatesUC,
        getCertificateUC,
        revokeCertificateUC
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("In-cluster CA service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) return cast(ushort) 9321;

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 9321;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
