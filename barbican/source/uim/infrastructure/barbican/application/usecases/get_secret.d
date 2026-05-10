module uim.infrastructure.barbican.application.usecases.get_secret;

import uim.infrastructure.barbican.domain.entities.secret : Secret;
import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

class GetSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    Secret* execute(string id) {
        return repository.findById(id);
    }
}
