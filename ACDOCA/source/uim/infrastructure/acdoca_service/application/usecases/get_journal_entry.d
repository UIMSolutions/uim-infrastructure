module uim.infrastructure.acdoca_service.application.usecases.get_journal_entry;

import uim.infrastructure.acdoca_service.domain.entities.journal_entry : MaybeJournalEntry;
import uim.infrastructure.acdoca_service.domain.ports.repositories.journal_entry_repository :
    IJournalEntryRepository;
import std.string : strip;

class GetJournalEntryUseCase {
    private IJournalEntryRepository repository;

    this(IJournalEntryRepository repository) {
        this.repository = repository;
    }

    MaybeJournalEntry execute(string id) {
        auto normalized = id.strip;
        if (normalized.length == 0) {
            return MaybeJournalEntry(false);
        }
        return repository.getById(normalized);
    }
}
