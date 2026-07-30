module uim.infrastructure.smtp_relay.application.usecases.get_message;

import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage;
import uim.infrastructure.smtp_relay.domain.ports.repositories.email_message_repository : IEmailMessageRepository;

class GetMessageUseCase {
    private IEmailMessageRepository repository;

    this(IEmailMessageRepository repository) {
        this.repository = repository;
    }

    EmailMessage* execute(string id) {
        EmailMessage message;
        if (!repository.findById(id, message)) {
            return null;
        }

        auto heapMessage = new EmailMessage;
        *heapMessage = message;
        return heapMessage;
    }
}
