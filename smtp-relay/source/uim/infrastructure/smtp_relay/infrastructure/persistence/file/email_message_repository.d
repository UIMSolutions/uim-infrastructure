module uim.infrastructure.smtp_relay.infrastructure.persistence.file.email_message_repository;

import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage;
import uim.infrastructure.smtp_relay.domain.ports.repositories.email_message_repository : IEmailMessageRepository;
import core.sync.mutex : Mutex;
import std.file : exists, mkdirRecurse, readText, rename, write;
import std.path : dirName;
import vibe.data.json : deserializeJson;
import vibe.data.json : serializeToPrettyJson;

class FileEmailMessageRepository : IEmailMessageRepository {
    private string filePath;
    private EmailMessage[] messages;
    private Mutex mutex;

    this(string filePath) {
        this.filePath = filePath;
        this.mutex = new Mutex;

        auto directory = dirName(filePath);
        if (directory.length > 0 && !exists(directory)) {
            mkdirRecurse(directory);
        }

        this.messages = loadFromDisk();
    }

    override void save(in EmailMessage message) {
        mutex.lock();
        scope(exit) mutex.unlock();

        auto copy = copyMessage(message);
        foreach (i, existing; messages) {
            if (existing.id == copy.id) {
                messages[i] = copy;
                persist();
                return;
            }
        }

        messages ~= copy;
        persist();
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

    private EmailMessage[] loadFromDisk() {
        if (!exists(filePath)) {
            return [];
        }

        auto text = readText(filePath);
        if (text.length == 0) {
            return [];
        }

        try {
            return deserializeJson!(EmailMessage[])(text);
        } catch (Exception ex) {
            throw new Exception("failed to deserialize message store at " ~ filePath ~ ": " ~ ex.msg);
        }
    }

    private void persist() {
        auto serialized = serializeToPrettyJson(messages);
        auto tempPath = filePath ~ ".tmp";
        write(tempPath, serialized);
        rename(tempPath, filePath);
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
