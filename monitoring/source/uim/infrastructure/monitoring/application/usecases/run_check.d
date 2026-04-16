module monitoring_service.application.usecases.run_check;

import monitoring_service.application.dto.check_command : RunCheckCommand;
import monitoring_service.domain.entities.check_result : CheckResult;
import monitoring_service.domain.ports.repositories.check : ICheckRepository;
import monitoring_service.domain.ports.runners.check : ICheckRunner;

class RunCheckUseCase {
    private ICheckRepository repository;
    private ICheckRunner runner;

    this(ICheckRepository repository, ICheckRunner runner) {
        this.repository = repository;
        this.runner     = runner;
    }

    /// Runs the check identified by command.id, stores the result, and returns it.
    /// Throws when the check id is not found.
    CheckResult execute(in RunCheckCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }

        auto check = repository.findById(command.id);
        if (check is null) {
            throw new Exception("check not found: " ~ command.id);
        }

        auto result = runner.run(*check);
        repository.saveResult(result);
        return result;
    }
}
