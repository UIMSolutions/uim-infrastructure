module uim.infrastructure.acdoca_service.application.dto.journal_entry_command;

struct CreateJournalEntryCommand {
    string companyCode;
    uint fiscalYear;
    uint documentNumber;
    uint lineItem;
    string glAccount;
    string currency;
    double amount;
    string indicator;
    string text;
    string postingDate;
}
