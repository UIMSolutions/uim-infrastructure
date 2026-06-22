module uim.infrastructure.vault.application.usecases.issue_certificate;

import uim.infrastructure.vault.application.dto.vault_command : IssueCertificateCommand;
import uim.infrastructure.vault.domain.entities.secret_record : CertificateRecord;
import uim.infrastructure.vault.domain.ports.secret_repository : ISecretRepository;

class IssueCertificateUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    CertificateRecord execute(IssueCertificateCommand command) {
        return repository.issueCertificate(command.commonName, command.ownerIdentity, command.ttlSeconds);
    }
}
