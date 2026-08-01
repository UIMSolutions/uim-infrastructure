module uim.infrastructure.acdoca_service.infrastructure.persistence.postgresql.sql_runner;

import std.process : execute;
import std.string : replace, split, splitLines;

class PostgreSqlSqlRunner {
    private string dsn;

    this(string dsn) {
        this.dsn = dsn;
        ensureSchema();
    }

    void exec(string sql) {
        auto result = execute([
            "psql",
            dsn,
            "-v", "ON_ERROR_STOP=1",
            "-At",
            "-F", "\t",
            "-c", sql
        ]);

        if (result.status != 0) {
            throw new Exception("postgres query failed: " ~ result.output);
        }
    }

    string[][] query(string sql) {
        auto result = execute([
            "psql",
            dsn,
            "-v", "ON_ERROR_STOP=1",
            "-At",
            "-F", "\t",
            "-c", sql
        ]);

        if (result.status != 0) {
            throw new Exception("postgres query failed: " ~ result.output);
        }

        string[][] rows;
        foreach (line; splitLines(result.output)) {
            if (line.length == 0) {
                continue;
            }
            rows ~= line.split("\t");
        }

        return rows;
    }

    string escape(string value) {
        return value.replace("'", "''");
    }

    private void ensureSchema() {
        exec(`
CREATE TABLE IF NOT EXISTS acdoca_journal_entries (
  id TEXT PRIMARY KEY,
  company_code TEXT NOT NULL,
  fiscal_year INTEGER NOT NULL,
  document_number INTEGER NOT NULL,
  line_item INTEGER NOT NULL,
  gl_account TEXT NOT NULL,
  currency TEXT NOT NULL,
  amount DOUBLE PRECISION NOT NULL,
  indicator TEXT NOT NULL,
  text_value TEXT NOT NULL,
  posting_date TEXT NOT NULL,
  created_at TEXT NOT NULL
);
`);
    }
}
