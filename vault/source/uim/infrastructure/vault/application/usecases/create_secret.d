module uim.infrastructure.vault.application.usecases.create_secret;

import uim.infrastructure.vault.application.dto.vault_command : CreateSecretCommand;
import uim.infrastructure.vault.domain.entities.secret_record : SecretRecord;
import uim.infrastructure.vault.domain.ports.secret_repository : ISecretRepository;

class CreateSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    SecretRecord execute(CreateSecretCommand command) {
        return repository.createSecret(
            command.path,
            command.value,
            command.ownerIdentity,
            command.category,
            command.ttlSeconds
        );
    }
}
