module monitoring_service.application.usecases.deregister_check;

import monitoring_service.application.dto.check_command : DeregisterCheckCommand;
import monitoring_service.domain.ports.repositories.check : ICheckRepository;

class DeregisterCheckUseCase {
    private ICheckRepository repository;

    this(ICheckRepository repository) {
        this.repository = repository;
    }

    void execute(in DeregisterCheckCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        repository.remove(command.id);
    }
}
