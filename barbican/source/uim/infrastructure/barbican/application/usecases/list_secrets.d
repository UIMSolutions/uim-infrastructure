module uim.infrastructure.barbican.application.usecases.list_secrets;

import uim.infrastructure.barbican.domain.entities.secret : Secret;
import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

class ListSecretsUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    Secret[] execute(string projectId = "") {
        return repository.list(projectId);
    }
}
