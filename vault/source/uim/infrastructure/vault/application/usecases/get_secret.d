module uim.infrastructure.vault.application.usecases.get_secret;

import uim.infrastructure.vault.domain.entities.secret_record : SecretRecord;
import uim.infrastructure.vault.domain.ports.secret_repository : ISecretRepository;

class GetSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    SecretRecord* execute(string id) {
        return repository.getSecretById(id);
    }
}
