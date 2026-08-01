module uim.infrastructure.acdoca_service.infrastructure.persistence.memory.journal_entry_repository;

import uim.infrastructure.acdoca_service.domain.entities.journal_entry : JournalEntry,
    MaybeJournalEntry;
import uim.infrastructure.acdoca_service.domain.ports.repositories.journal_entry_repository :
    IJournalEntryRepository;

class InMemoryJournalEntryRepository : IJournalEntryRepository {
    private JournalEntry[string] byId;
    private string[] idOrder;

    override JournalEntry add(JournalEntry entry) {
        byId[entry.id] = entry;
        idOrder ~= entry.id;
        return entry;
    }

    override JournalEntry[] listAll() {
        JournalEntry[] outValues;
        foreach (id; idOrder) {
            if (auto item = id in byId) {
                outValues ~= *item;
            }
        }
        return outValues;
    }

    override MaybeJournalEntry getById(string id) {
        if (auto item = id in byId) {
            return MaybeJournalEntry(true, *item);
        }
        return MaybeJournalEntry(false);
    }

    override bool removeById(string id) {
        if (!byId.remove(id)) {
            return false;
        }

        string[] newOrder;
        foreach (existing; idOrder) {
            if (existing != id) {
                newOrder ~= existing;
            }
        }
        idOrder = newOrder;

        return true;
    }
}
