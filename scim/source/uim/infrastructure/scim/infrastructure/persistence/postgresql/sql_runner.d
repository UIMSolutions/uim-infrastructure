module uim.infrastructure.scim.infrastructure.persistence.postgresql.sql_runner;

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
CREATE TABLE IF NOT EXISTS scim_users (
  id TEXT PRIMARY KEY,
  external_id TEXT NOT NULL,
  user_name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  given_name TEXT NOT NULL,
  family_name TEXT NOT NULL,
  emails TEXT NOT NULL,
  created_at TEXT NOT NULL,
  last_modified_at TEXT NOT NULL,
  version_tag TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS scim_groups (
  id TEXT PRIMARY KEY,
  external_id TEXT NOT NULL,
  display_name TEXT NOT NULL UNIQUE,
  member_ids TEXT NOT NULL,
  created_at TEXT NOT NULL,
  last_modified_at TEXT NOT NULL,
  version_tag TEXT NOT NULL
);
`);
    }
}
