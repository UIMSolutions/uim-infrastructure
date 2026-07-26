module uim.infrastructure.ca.application.usecases.list_certificates;

import uim.infrastructure.ca.domain.entities.certificate : Certificate;
import uim.infrastructure.ca.domain.ports.repositories.certificate : ICertificateRepository;

class ListCertificatesUseCase {
    private ICertificateRepository repository;

    this(ICertificateRepository repository) {
        this.repository = repository;
    }

    Certificate[] execute(string namespaceName = "") {
        return repository.list(namespaceName);
    }
}
