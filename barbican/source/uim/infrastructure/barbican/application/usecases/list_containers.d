module uim.infrastructure.barbican.application.usecases.list_containers;

import uim.infrastructure.barbican.domain.entities.secret_container : SecretContainer;
import uim.infrastructure.barbican.domain.ports.repositories.secret_container : ISecretContainerRepository;

class ListContainersUseCase {
    private ISecretContainerRepository repository;

    this(ISecretContainerRepository repository) {
        this.repository = repository;
    }

    SecretContainer[] execute(string projectId = "") {
        return repository.list(projectId);
    }
}
