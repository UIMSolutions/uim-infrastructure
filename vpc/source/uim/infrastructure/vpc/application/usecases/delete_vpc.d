module vpc_service.application.usecases.delete_vpc;

import vpc_service.application.dto.vpc_commands : DeleteVpcCommand;
import vpc_service.domain.ports.repositories.vpc : IVpcRepository;

class DeleteVpcUseCase {
    private IVpcRepository repository;

    this(IVpcRepository repository) {
        this.repository = repository;
    }

    void execute(in DeleteVpcCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        repository.remove(command.id);
    }
}
