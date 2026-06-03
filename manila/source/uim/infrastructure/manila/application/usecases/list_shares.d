module uim.infrastructure.manila.application.usecases.list_shares;

import uim.infrastructure.manila.domain.entities.share : Share;
import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;

class ListSharesUseCase {
    private IShareRepository repository;

    this(IShareRepository repository) {
        this.repository = repository;
    }

    Share[] execute(string projectId = "") {
        if (projectId.length == 0) {
            return repository.list();
        }
        return repository.listByProject(projectId);
    }
}