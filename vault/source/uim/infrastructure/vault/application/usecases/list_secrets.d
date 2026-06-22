module uim.infrastructure.vault.application.usecases.list_secrets;

import uim.infrastructure.vault.domain.entities.secret_record : SecretRecord;
import uim.infrastructure.vault.domain.ports.secret_repository : ISecretRepository;

class ListSecretsUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    SecretRecord[] execute() {
        return repository.listSecrets();
    }
}
