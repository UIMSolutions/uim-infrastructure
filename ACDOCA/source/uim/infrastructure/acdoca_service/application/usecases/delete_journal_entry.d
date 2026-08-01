module uim.infrastructure.acdoca_service.application.usecases.delete_journal_entry;

import uim.infrastructure.acdoca_service.domain.ports.repositories.journal_entry_repository :
    IJournalEntryRepository;
import std.string : strip;

class DeleteJournalEntryUseCase {
    private IJournalEntryRepository repository;

    this(IJournalEntryRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        auto normalized = id.strip;
        if (normalized.length == 0) {
            throw new Exception("id is required");
        }

        if (!repository.removeById(normalized)) {
            throw new Exception("journal entry not found");
        }
    }
}
