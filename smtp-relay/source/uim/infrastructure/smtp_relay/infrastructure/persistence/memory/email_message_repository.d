module uim.infrastructure.smtp_relay.infrastructure.persistence.memory.email_message_repository;

import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage;
import uim.infrastructure.smtp_relay.domain.ports.repositories.email_message_repository : IEmailMessageRepository;
import core.sync.mutex : Mutex;

class InMemoryEmailMessageRepository : IEmailMessageRepository {
    private EmailMessage[] messages;
    private Mutex mutex;

    this() {
        this.mutex = new Mutex;
    }

    override void save(in EmailMessage message) {
        mutex.lock();
        scope(exit) mutex.unlock();

        auto copy = copyMessage(message);
        foreach (i, existing; messages) {
            if (existing.id == copy.id) {
                messages[i] = copy;
                return;
            }
        }

        messages ~= copy;
    }

    override EmailMessage[] list() {
        mutex.lock();
        scope(exit) mutex.unlock();

        EmailMessage[] outMessages;
        foreach (message; messages) {
            outMessages ~= copyMessage(message);
        }
        return outMessages;
    }

    override bool findById(string id, out EmailMessage message) {
        mutex.lock();
        scope(exit) mutex.unlock();

        foreach (candidate; messages) {
            if (candidate.id == id) {
                message = copyMessage(candidate);
                return true;
            }
        }

        return false;
    }

    private EmailMessage copyMessage(in EmailMessage source) {
        EmailMessage message;
        message.id = source.id.idup;
        message.sender = source.sender.idup;
        message.recipients = source.recipients.dup;
        message.subject = source.subject.idup;
        message.body = source.body.idup;
        message.createdAt = source.createdAt;
        message.status = source.status;
        message.relayError = source.relayError.idup;
        return message;
    }
}
