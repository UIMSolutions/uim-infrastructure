module uim.infrastructure.acdoca_service.application.usecases.create_journal_entry;

import uim.infrastructure.acdoca_service.application.dto.journal_entry_command :
    CreateJournalEntryCommand;
import uim.infrastructure.acdoca_service.domain.entities.journal_entry : DebitCreditIndicator,
    JournalEntry;
import uim.infrastructure.acdoca_service.domain.ports.repositories.journal_entry_repository :
    IJournalEntryRepository;
import std.conv : to;
import std.datetime : Date;
import std.datetime.systime : Clock, SysTime;
import std.string : replace, split, strip, toLower;

class CreateJournalEntryUseCase {
    private IJournalEntryRepository repository;

    this(IJournalEntryRepository repository) {
        this.repository = repository;
    }

    JournalEntry execute(CreateJournalEntryCommand command) {
        auto companyCode = command.companyCode.strip;
        auto glAccount = command.glAccount.strip;
        auto currency = command.currency.strip;

        if (companyCode.length == 0) {
            throw new Exception("companyCode is required");
        }
        if (glAccount.length == 0) {
            throw new Exception("glAccount is required");
        }
        if (currency.length == 0) {
            throw new Exception("currency is required");
        }
        if (command.amount <= 0) {
            throw new Exception("amount must be greater than zero");
        }

        auto indicator = parseIndicator(command.indicator);
        auto postingDate = parsePostingDate(command.postingDate);

        auto entry = JournalEntry(
            generateId(command),
            companyCode,
            command.fiscalYear,
            command.documentNumber,
            command.lineItem,
            glAccount,
            currency,
            command.amount,
            indicator,
            command.text.strip,
            postingDate,
            Clock.currTime()
        );

        return repository.add(entry);
    }

    private string generateId(CreateJournalEntryCommand command) {
        auto base = command.companyCode.strip ~ "-" ~ command.fiscalYear.to!string ~ "-" ~
            command.documentNumber.to!string ~ "-" ~ command.lineItem.to!string;
        auto normalized = base.toLower.replace(" ", "-").replace("/", "-");
        return normalized ~ "-" ~ Clock.currTime().stdTime.to!string;
    }

    private DebitCreditIndicator parseIndicator(string value) {
        auto normalized = value.strip.toLower;
        if (normalized == "debit") {
            return DebitCreditIndicator.debit;
        }
        if (normalized == "credit") {
            return DebitCreditIndicator.credit;
        }
        throw new Exception("indicator must be debit or credit");
    }

    private SysTime parsePostingDate(string value) {
        auto normalized = value.strip;
        if (normalized.length == 0) {
            return Clock.currTime();
        }

        auto parts = normalized.split("-");
        if (parts.length != 3) {
            throw new Exception("postingDate must be YYYY-MM-DD");
        }

        auto y = parts[0].to!int;
        auto m = parts[1].to!int;
        auto d = parts[2].to!int;

        return SysTime(Date(y, m, d));
    }
}
