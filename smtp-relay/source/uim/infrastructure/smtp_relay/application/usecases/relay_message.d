module uim.infrastructure.smtp_relay.application.usecases.relay_message;

import uim.infrastructure.smtp_relay.application.dto.relay_message_command : RelayMessageCommand;
import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage, MessageStatus;
import uim.infrastructure.smtp_relay.domain.ports.repositories.email_message_repository : IEmailMessageRepository;
import uim.infrastructure.smtp_relay.domain.ports.services.smtp_relay_port : ISmtpRelayPort;
import std.datetime.systime : Clock;
import std.string : indexOf, strip;
import std.uuid : randomUUID;

class RelayMessageUseCase {
    private IEmailMessageRepository repository;
    private ISmtpRelayPort relayPort;
    private string defaultSender;

    this(
        IEmailMessageRepository repository,
        ISmtpRelayPort relayPort,
        string defaultSender
    ) {
        this.repository = repository;
        this.relayPort = relayPort;
        this.defaultSender = defaultSender;
    }

    EmailMessage execute(in RelayMessageCommand command) {
        auto normalizedSender = normalizeSender(command.sender);
        auto normalizedRecipients = normalizeRecipients(command.recipients);
        auto normalizedSubject = command.subject.strip;
        auto normalizedBody = command.body.strip;

        validate(normalizedSender, normalizedRecipients, normalizedSubject, normalizedBody);

        EmailMessage message;
        message.id = randomUUID().toString();
        message.sender = normalizedSender;
        message.recipients = normalizedRecipients;
        message.subject = normalizedSubject;
        message.body = normalizedBody;
        message.createdAt = Clock.currTime();
        message.status = MessageStatus.queued;
        message.relayError = "";

        repository.save(message);

        try {
            relayPort.relay(message);
            message.status = MessageStatus.relayed;
            message.relayError = "";
            repository.save(message);
            return message;
        } catch (Exception ex) {
            message.status = MessageStatus.failed;
            message.relayError = ex.msg;
            repository.save(message);
            throw new Exception("smtp relay failed: " ~ ex.msg);
        }
    }

    private void validate(
        string sender,
        string[] recipients,
        string subject,
        string body
    ) {
        if (sender.length == 0 || sender.indexOf("@") < 0) {
            throw new Exception("a valid sender address is required");
        }

        if (recipients.length == 0) {
            throw new Exception("at least one recipient is required");
        }

        foreach (recipient; recipients) {
            if (recipient.length == 0 || recipient.indexOf("@") < 0) {
                throw new Exception("every recipient must be a valid email address");
            }
        }

        if (subject.length == 0) {
            throw new Exception("subject is required");
        }

        if (body.length == 0) {
            throw new Exception("body is required");
        }
    }

    private string normalizeSender(string sender) {
        auto normalized = sender.strip;
        if (normalized.length == 0) {
            normalized = defaultSender.strip;
        }
        return normalized;
    }

    private string[] normalizeRecipients(scope const(string)[] recipients) {
        string[] outRecipients;
        foreach (recipient; recipients) {
            auto value = recipient.strip;
            if (value.length > 0) {
                outRecipients ~= value;
            }
        }
        return outRecipients;
    }
}
