module uim.infrastructure.acdoca_service.domain.entities.journal_entry;

import std.datetime.systime : SysTime;

enum DebitCreditIndicator {
    debit,
    credit
}

struct JournalEntry {
    string id;
    string companyCode;
    uint fiscalYear;
    uint documentNumber;
    uint lineItem;
    string glAccount;
    string currency;
    double amount;
    DebitCreditIndicator indicator;
    string text;
    SysTime postingDate;
    SysTime createdAt;
}

struct MaybeJournalEntry {
    bool found;
    JournalEntry value;
}
