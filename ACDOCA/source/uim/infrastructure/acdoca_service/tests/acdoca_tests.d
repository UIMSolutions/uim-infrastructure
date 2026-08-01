module uim.infrastructure.acdoca_service.tests.acdoca_tests;

import uim.infrastructure.acdoca_service.application.dto.journal_entry_command :
    CreateJournalEntryCommand;
import uim.infrastructure.acdoca_service.application.usecases.create_journal_entry :
    CreateJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.delete_journal_entry :
    DeleteJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.get_journal_entry :
    GetJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.list_journal_entries :
    ListJournalEntriesUseCase;
import uim.infrastructure.acdoca_service.infrastructure.http.security.write_auth_middleware :
    WriteAuthMiddleware;
import uim.infrastructure.acdoca_service.infrastructure.persistence.memory.journal_entry_repository :
    InMemoryJournalEntryRepository;
import std.exception : collectException;

unittest {
    auto repo = new InMemoryJournalEntryRepository();
    auto createUseCase = new CreateJournalEntryUseCase(repo);
    auto listUseCase = new ListJournalEntriesUseCase(repo);
    auto getUseCase = new GetJournalEntryUseCase(repo);
    auto deleteUseCase = new DeleteJournalEntryUseCase(repo);

    auto created = createUseCase.execute(CreateJournalEntryCommand(
        "1000",
        2026,
        900100,
        1,
        "400000",
        "EUR",
        2500.50,
        "debit",
        "invoice posting",
        "2026-07-25"
    ));

    assert(created.id.length > 0);
    assert(listUseCase.execute().length == 1);

    auto fetched = getUseCase.execute(created.id);
    assert(fetched.found);
    assert(fetched.value.companyCode == "1000");

    deleteUseCase.execute(created.id);
    assert(listUseCase.execute().length == 0);
}

unittest {
    auto repo = new InMemoryJournalEntryRepository();
    auto createUseCase = new CreateJournalEntryUseCase(repo);

    auto err = collectException(createUseCase.execute(CreateJournalEntryCommand(
        "1000",
        2026,
        900101,
        1,
        "400000",
        "EUR",
        0,
        "debit",
        "",
        "2026-07-25"
    )));

    assert(err !is null);
}

unittest {
    auto jwtMiddleware = new WriteAuthMiddleware(
        "jwt",
        "",
        "aaa.bbb.ccc",
        "acdoca.write",
        ""
    );

    assert(jwtMiddleware.isAuthorizedHeader("Bearer aaa.bbb.ccc"));
    assert(!jwtMiddleware.isAuthorizedHeader("Bearer aaa.bbb"));

    auto oauthMiddleware = new WriteAuthMiddleware(
        "oauth2",
        "",
        "",
        "acdoca.write",
        "tok1=acdoca.read|acdoca.write;tok2=acdoca.read"
    );

    assert(oauthMiddleware.isAuthorizedHeader("Bearer tok1"));
    assert(!oauthMiddleware.isAuthorizedHeader("Bearer tok2"));
}
