module uim.infrastructure.barbican.application.usecases.get_container;

import uim.infrastructure.barbican.domain.entities.secret_container : SecretContainer;
import uim.infrastructure.barbican.domain.ports.repositories.secret_container : ISecretContainerRepository;

class GetContainerUseCase {
    private ISecretContainerRepository repository;

    this(ISecretContainerRepository repository) {
        this.repository = repository;
    }

    SecretContainer* execute(string id) {
        return repository.findById(id);
    }
}
