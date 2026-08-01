module uim.infrastructure.acdoca_service.domain.ports.repositories.journal_entry_repository;

import uim.infrastructure.acdoca_service.domain.entities.journal_entry : JournalEntry,
    MaybeJournalEntry;

interface IJournalEntryRepository {
    JournalEntry add(JournalEntry entry);
    JournalEntry[] listAll();
    MaybeJournalEntry getById(string id);
    bool removeById(string id);
}
