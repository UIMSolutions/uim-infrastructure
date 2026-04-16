module log_service.application.usecases.write_log;

import log_service.application.dto.log_command : WriteLogCommand;
import log_service.domain.entities.log_entry : LogEntry, parseLogLevel;
import log_service.domain.ports.repositories.logs : ILogsRepository;
import std.datetime.systime : Clock;
import std.format : format;
import std.uuid : randomUUID;

class WriteLogUseCase {
    private ILogsRepository repository;

    this(ILogsRepository repository) {
        this.repository = repository;
    }

    LogEntry execute(in WriteLogCommand command) {
        enforceCommand(command);

        auto entry = LogEntry(
            randomUUID().toString(),
            parseLogLevel(command.level),
            command.message,
            command.service,
            Clock.currTime().toISOExtString()
        );

        repository.save(entry);
        return entry;
    }

    private void enforceCommand(in WriteLogCommand command) {
        if (command.service.length == 0) {
            throw new Exception("service must not be empty");
        }
        if (command.level.length == 0) {
            throw new Exception("level must not be empty");
        }
        if (command.message.length == 0) {
            throw new Exception("message must not be empty");
        }
    }
}
