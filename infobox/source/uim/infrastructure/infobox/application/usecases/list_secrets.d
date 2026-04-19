module uim.infrastructure.infobox.application.usecases.list_secrets;

import uim.infrastructure.infobox.application.dto.commands : ListSecretsQuery;
import uim.infrastructure.infobox.domain.entities.secret : Secret;
import uim.infrastructure.infobox.domain.ports.repositories.secret : ISecretRepository;

class ListSecretsUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    Secret[] execute(in ListSecretsQuery query) {
        if (query.projectId.length == 0) {
            throw new Exception("project id must not be empty");
        }
        return repository.listByProject(query.projectId);
    }
}
