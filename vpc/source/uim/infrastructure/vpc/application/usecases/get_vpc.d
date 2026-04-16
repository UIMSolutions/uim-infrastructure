module vpc_service.application.usecases.get_vpc;

import vpc_service.domain.entities.vpc : Vpc;
import vpc_service.domain.ports.repositories.vpc : IVpcRepository;

class GetVpcUseCase {
    private IVpcRepository repository;

    this(IVpcRepository repository) {
        this.repository = repository;
    }

    /// Returns a pointer to the matching VPC, or null when not found.
    Vpc* execute(string id) {
        if (id.length == 0) {
            throw new Exception("id must not be empty");
        }
        return repository.findById(id);
    }
}
