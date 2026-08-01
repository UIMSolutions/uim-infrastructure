module uim.infrastructure.acdoca_service.infrastructure.persistence.postgresql.journal_entry_repository;

import uim.infrastructure.acdoca_service.domain.entities.journal_entry : DebitCreditIndicator,
    JournalEntry, MaybeJournalEntry;
import uim.infrastructure.acdoca_service.domain.ports.repositories.journal_entry_repository :
    IJournalEntryRepository;
import uim.infrastructure.acdoca_service.infrastructure.persistence.postgresql.sql_runner :
    PostgreSqlSqlRunner;
import std.conv : to;
import std.datetime : DateTimeException;
import std.datetime.systime : SysTime;

class PostgreSqlJournalEntryRepository : IJournalEntryRepository {
    private PostgreSqlSqlRunner sql;

    this(string dsn) {
        sql = new PostgreSqlSqlRunner(dsn);
    }

    override JournalEntry add(JournalEntry entry) {
        auto stmt = "INSERT INTO acdoca_journal_entries (" ~
            "id, company_code, fiscal_year, document_number, line_item, gl_account, currency, amount, indicator, text_value, posting_date, created_at" ~
            ") VALUES (" ~
            quote(entry.id) ~ "," ~
            quote(entry.companyCode) ~ "," ~
            entry.fiscalYear.to!string ~ "," ~
            entry.documentNumber.to!string ~ "," ~
            entry.lineItem.to!string ~ "," ~
            quote(entry.glAccount) ~ "," ~
            quote(entry.currency) ~ "," ~
            entry.amount.to!string ~ "," ~
            quote(indicatorToString(entry.indicator)) ~ "," ~
            quote(entry.text) ~ "," ~
            quote(entry.postingDate.toISOExtString()) ~ "," ~
            quote(entry.createdAt.toISOExtString()) ~
            ");";
        sql.exec(stmt);
        return entry;
    }

    override JournalEntry[] listAll() {
        auto rows = sql.query("SELECT id, company_code, fiscal_year, document_number, line_item, gl_account, currency, amount, indicator, text_value, posting_date, created_at FROM acdoca_journal_entries ORDER BY created_at DESC;");
        JournalEntry[] entries;
        foreach (row; rows) {
            entries ~= fromRow(row);
        }
        return entries;
    }

    override MaybeJournalEntry getById(string id) {
        auto rows = sql.query("SELECT id, company_code, fiscal_year, document_number, line_item, gl_account, currency, amount, indicator, text_value, posting_date, created_at FROM acdoca_journal_entries WHERE id = " ~ quote(id) ~ " LIMIT 1;");
        if (rows.length == 0) {
            return MaybeJournalEntry(false);
        }
        return MaybeJournalEntry(true, fromRow(rows[0]));
    }

    override bool removeById(string id) {
        auto existing = getById(id);
        if (!existing.found) {
            return false;
        }

        sql.exec("DELETE FROM acdoca_journal_entries WHERE id = " ~ quote(id) ~ ";");
        return true;
    }

    private JournalEntry fromRow(string[] row) {
        if (row.length < 12) {
            throw new Exception("invalid postgres row for journal entry");
        }

        return JournalEntry(
            row[0],
            row[1],
            row[2].to!uint,
            row[3].to!uint,
            row[4].to!uint,
            row[5],
            row[6],
            row[7].to!double,
            parseIndicator(row[8]),
            row[9],
            parseDate(row[10]),
            parseDate(row[11])
        );
    }

    private DebitCreditIndicator parseIndicator(string value) {
        return value == "credit" ? DebitCreditIndicator.credit : DebitCreditIndicator.debit;
    }

    private string indicatorToString(DebitCreditIndicator indicator) {
        return indicator == DebitCreditIndicator.credit ? "credit" : "debit";
    }

    private SysTime parseDate(string value) {
        try {
            return SysTime.fromISOExtString(value);
        } catch (DateTimeException) {
            return SysTime.init;
        }
    }

    private string quote(string value) {
        return "'" ~ sql.escape(value) ~ "'";
    }
}
