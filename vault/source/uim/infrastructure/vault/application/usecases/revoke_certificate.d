module uim.infrastructure.vault.application.usecases.revoke_certificate;

import uim.infrastructure.vault.domain.ports.secret_repository : ISecretRepository;

class RevokeCertificateUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    bool execute(string serial) {
        return repository.revokeCertificate(serial);
    }
}
