module monitoring_service.application.usecases.register_check;

import monitoring_service.application.dto.check_command : RegisterCheckCommand;
import monitoring_service.domain.entities.check : Check;
import monitoring_service.domain.ports.repositories.check : ICheckRepository;

class RegisterCheckUseCase {
    private ICheckRepository repository;

    this(ICheckRepository repository) {
        this.repository = repository;
    }

    Check execute(in RegisterCheckCommand command) {
        enforceCommand(command);

        auto check = Check(
            command.id,
            command.name,
            command.host,
            command.port,
            command.intervalSecs == 0 ? 30 : command.intervalSecs,
            true
        );

        repository.save(check);
        return check;
    }

    private void enforceCommand(in RegisterCheckCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        if (command.name.length == 0) {
            throw new Exception("name must not be empty");
        }
        if (command.host.length == 0) {
            throw new Exception("host must not be empty");
        }
        if (command.port == 0) {
            throw new Exception("port must be greater than zero");
        }
    }
}
