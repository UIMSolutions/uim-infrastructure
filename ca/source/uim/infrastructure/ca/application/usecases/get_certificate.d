/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.application.usecases.get_certificate;

import uim.infrastructure.ca.domain.entities.certificate : Certificate;
import uim.infrastructure.ca.domain.ports.repositories.certificate : ICertificateRepository;

class GetCertificateUseCase {
    private ICertificateRepository repository;

    this(ICertificateRepository repository) {
        this.repository = repository;
    }

    Certificate* execute(string id) {
        return repository.findById(id);
    }
}
