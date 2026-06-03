module uim.infrastructure.manila.application.usecases.list_share_types;

import uim.infrastructure.manila.domain.entities.share_type : ShareType;
import uim.infrastructure.manila.domain.ports.repositories.share_type : IShareTypeRepository;

class ListShareTypesUseCase {
    private IShareTypeRepository repository;

    this(IShareTypeRepository repository) {
        this.repository = repository;
    }

    ShareType[] execute() {
        return repository.list();
    }
}