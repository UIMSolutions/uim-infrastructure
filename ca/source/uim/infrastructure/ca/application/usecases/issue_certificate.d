module uim.infrastructure.ca.application.usecases.issue_certificate;

import std.datetime : Clock, days;
import std.digest : toHexString;
import std.digest.sha : sha256Of;
import uim.infrastructure.ca.application.dto.commands : IssueCertificateCommand;
import uim.infrastructure.ca.domain.entities.ca_state : CaState;
import uim.infrastructure.ca.domain.entities.certificate : Certificate, CertificateStatus;
import uim.infrastructure.ca.domain.ports.repositories.ca_state : ICaStateRepository;
import uim.infrastructure.ca.domain.ports.repositories.certificate : ICertificateRepository;
import uim.infrastructure.ca.domain.ports.crypto.ca_engine : ICaCryptoEngine;

class IssueCertificateUseCase {
    private ICaStateRepository caRepository;
    private ICertificateRepository certificateRepository;
    private ICaCryptoEngine engine;

    this(
        ICaStateRepository caRepository,
        ICertificateRepository certificateRepository,
        ICaCryptoEngine engine
    ) {
        this.caRepository = caRepository;
        this.certificateRepository = certificateRepository;
        this.engine = engine;
    }

    Certificate execute(in IssueCertificateCommand cmd) {
        enforce(cmd.commonName.length > 0, "commonName must not be empty");

        auto statePtr = caRepository.get();
        if (statePtr is null) {
            throw new Exception("CA is not initialized");
        }

        auto effectiveDays = cmd.validDays > 0 ? cmd.validDays : 365;
        auto state = *statePtr;
        auto material = engine.issueCertificate(
            state.certPem,
            state.keyPem,
            cmd.commonName,
            cmd.subjectAltNames.dup,
            effectiveDays
        );

        auto nowTs = Clock.currTime;
        auto now = nowTs.toISOExtString();
        auto notAfter = (nowTs + days(effectiveDays)).toISOExtString();

        auto certificate = Certificate(
            generateId(cmd.commonName),
            cmd.commonName,
            cmd.subjectAltNames.dup,
            material.certPem,
            material.keyPem,
            material.chainPem,
            material.serialNumber,
            CertificateStatus.active,
            now,
            now,
            notAfter,
            "",
            "",
            cmd.namespaceName
        );

        certificateRepository.save(certificate);
        return certificate;
    }

    private void enforce(bool condition, string message) {
        if (!condition) throw new Exception(message);
    }

    private string generateId(string seed) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(seed ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
