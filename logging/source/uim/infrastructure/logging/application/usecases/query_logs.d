module log_service.application.usecases.query_logs;

import log_service.application.dto.log_command : QueryLogsQuery;
import log_service.domain.entities.log_entry : LogEntry, parseLogLevel;
import log_service.domain.ports.repositories.logs : ILogsRepository;

class QueryLogsUseCase {
    private ILogsRepository repository;

    this(ILogsRepository repository) {
        this.repository = repository;
    }

    LogEntry[] execute(in QueryLogsQuery query) {
        if (query.service.length == 0) {
            throw new Exception("service must not be empty");
        }

        if (query.level.length == 0) {
            return repository.findByService(query.service);
        }

        return repository.findByServiceAndLevel(query.service, parseLogLevel(query.level));
    }
}
