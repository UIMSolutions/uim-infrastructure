module uim.infrastructure.smtp_relay.domain.entities.email_message;

import std.datetime.systime : SysTime;

enum MessageStatus {
    queued,
    relayed,
    failed
}

struct EmailMessage {
    string id;
    string sender;
    string[] recipients;
    string subject;
    string body;
    SysTime createdAt;
    MessageStatus status;
    string relayError;
}
