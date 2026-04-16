module log_service.application.dto.log_command;

struct WriteLogCommand {
    string service;
    string level;
    string message;
}

struct QueryLogsQuery {
    string service;
    string level;
}
