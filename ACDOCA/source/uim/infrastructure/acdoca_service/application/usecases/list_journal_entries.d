module uim.infrastructure.acdoca_service.application.usecases.list_journal_entries;

import uim.infrastructure.acdoca_service.domain.entities.journal_entry : JournalEntry;
import uim.infrastructure.acdoca_service.domain.ports.repositories.journal_entry_repository :
    IJournalEntryRepository;

class ListJournalEntriesUseCase {
    private IJournalEntryRepository repository;

    this(IJournalEntryRepository repository) {
        this.repository = repository;
    }

    JournalEntry[] execute() {
        return repository.listAll();
    }
}
