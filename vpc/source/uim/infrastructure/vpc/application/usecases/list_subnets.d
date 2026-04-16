module vpc_service.application.usecases.list_subnets;

import vpc_service.domain.entities.subnet : Subnet;
import vpc_service.domain.ports.repositories.subnet : ISubnetRepository;

class ListSubnetsUseCase {
    private ISubnetRepository repository;

    this(ISubnetRepository repository) {
        this.repository = repository;
    }

    Subnet[] execute() {
        return repository.list();
    }

    Subnet[] executeByVpc(string vpcId) {
        if (vpcId.length == 0) {
            throw new Exception("vpcId must not be empty");
        }
        return repository.listByVpc(vpcId);
    }
}
