module uim.infrastructure.manila.application.usecases.get_share;

import uim.infrastructure.manila.domain.entities.share : Share;
import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;

class GetShareUseCase {
    private IShareRepository repository;

    this(IShareRepository repository) {
        this.repository = repository;
    }

    Share* execute(string id) {
        if (id.length == 0) {
            throw new Exception("share id must not be empty");
        }
        return repository.findById(id);
    }
}