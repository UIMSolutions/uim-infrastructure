module log_service.domain.ports.repositories.logs;

import log_service.domain.entities.log_entry : LogEntry, LogLevel;

interface ILogsRepository {
    void save(in LogEntry entry);
    LogEntry[] list();
    LogEntry[] findByService(string service);
    LogEntry[] findByServiceAndLevel(string service, LogLevel level);
}
