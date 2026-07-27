/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.application.usecases.revoke_certificate;

import std.datetime : Clock;
import uim.infrastructure.ca.application.dto.commands : RevokeCertificateCommand;
import uim.infrastructure.ca.domain.ports.repositories.certificate : ICertificateRepository;

class RevokeCertificateUseCase {
    private ICertificateRepository repository;

    this(ICertificateRepository repository) {
        this.repository = repository;
    }

    void execute(in RevokeCertificateCommand cmd) {
        if (cmd.certificateId.length == 0) {
            throw new Exception("certificateId must not be empty");
        }

        auto ok = repository.revoke(
            cmd.certificateId,
            cmd.reason.length > 0 ? cmd.reason : "unspecified",
            Clock.currTime.toISOExtString()
        );
        if (!ok) {
            throw new Exception("certificate not found");
        }
    }
}
