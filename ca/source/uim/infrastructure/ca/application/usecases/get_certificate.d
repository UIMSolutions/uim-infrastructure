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
