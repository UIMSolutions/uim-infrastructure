module lb_service.application.usecases.deregister_backend;

import lb_service.application.dto.backend_command : DeregisterBackendCommand;
import lb_service.domain.ports.repositories.backend : IBackendRepository;

class DeregisterBackendUseCase {
    private IBackendRepository repository;

    this(IBackendRepository repository) {
        this.repository = repository;
    }

    void execute(in DeregisterBackendCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        repository.remove(command.id);
    }
}
