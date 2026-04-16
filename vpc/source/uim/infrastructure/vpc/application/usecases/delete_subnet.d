module vpc_service.application.usecases.delete_subnet;

import vpc_service.application.dto.vpc_commands : DeleteSubnetCommand;
import vpc_service.domain.ports.repositories.subnet : ISubnetRepository;

class DeleteSubnetUseCase {
    private ISubnetRepository repository;

    this(ISubnetRepository repository) {
        this.repository = repository;
    }

    void execute(in DeleteSubnetCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        repository.remove(command.id);
    }
}
