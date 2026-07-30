module uim.infrastructure.smtp_relay.domain.ports.repositories.email_message_repository;

import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage;

interface IEmailMessageRepository {
    void save(in EmailMessage message);
    EmailMessage[] list();
    bool findById(string id, out EmailMessage message);
}
