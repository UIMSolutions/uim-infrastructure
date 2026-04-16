module vpc_service.application.usecases.list_vpcs;

import vpc_service.domain.entities.vpc : Vpc;
import vpc_service.domain.ports.repositories.vpc : IVpcRepository;

class ListVpcsUseCase {
    private IVpcRepository repository;

    this(IVpcRepository repository) {
        this.repository = repository;
    }

    Vpc[] execute() {
        return repository.list();
    }
}
