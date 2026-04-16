module log_service.application.usecases.list_logs;

import log_service.domain.entities.log_entry : LogEntry;
import log_service.domain.ports.repositories.logs : ILogsRepository;

class ListLogsUseCase {
    private ILogsRepository repository;

    this(ILogsRepository repository) {
        this.repository = repository;
    }

    LogEntry[] execute() {
        return repository.list();
    }
}
