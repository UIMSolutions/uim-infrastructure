module uim.infrastructure.smtp_relay.application.dto.relay_message_command;

struct RelayMessageCommand {
    string sender;
    string[] recipients;
    string subject;
    string body;
}
