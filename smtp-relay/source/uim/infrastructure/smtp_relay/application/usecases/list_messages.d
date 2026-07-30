module uim.infrastructure.smtp_relay.application.usecases.list_messages;

import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage;
import uim.infrastructure.smtp_relay.domain.ports.repositories.email_message_repository : IEmailMessageRepository;

class ListMessagesUseCase {
    private IEmailMessageRepository repository;

    this(IEmailMessageRepository repository) {
        this.repository = repository;
    }

    EmailMessage[] execute() {
        return repository.list();
    }
}
