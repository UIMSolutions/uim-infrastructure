module vpc_service.application.usecases.create_vpc;

import vpc_service.application.dto.vpc_commands : CreateVpcCommand;
import vpc_service.domain.entities.vpc : Vpc, VpcState;
import vpc_service.domain.ports.repositories.vpc : IVpcRepository;

class CreateVpcUseCase {
    private IVpcRepository repository;

    this(IVpcRepository repository) {
        this.repository = repository;
    }

    Vpc execute(in CreateVpcCommand command) {
        enforceCommand(command);

        auto vpc = Vpc(
            command.id,
            command.name,
            command.cidr,
            command.region,
            VpcState.available
        );

        repository.save(vpc);
        return vpc;
    }

    private void enforceCommand(in CreateVpcCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        if (command.name.length == 0) {
            throw new Exception("name must not be empty");
        }
        if (command.cidr.length == 0) {
            throw new Exception("cidr must not be empty");
        }
        if (command.region.length == 0) {
            throw new Exception("region must not be empty");
        }
    }
}
