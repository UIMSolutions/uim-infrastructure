module uim.infrastructure.manila.infrastructure.persistence.postgresql.sql_runner;

import std.process : execute;
import std.string : split, splitLines, replace;

/// Lightweight PostgreSQL adapter using the psql CLI for persistence.
/// Requires psql installed in the runtime environment.
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
            throw new Exception("postgres query failed: " ~ result.errorOutput);
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
            throw new Exception("postgres query failed: " ~ result.errorOutput);
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
CREATE TABLE IF NOT EXISTS manila_share_types (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  protocol TEXT NOT NULL,
  driver_handles_share_servers BOOLEAN NOT NULL,
  snapshot_support BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS manila_shares (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  size_gib BIGINT NOT NULL,
  protocol TEXT NOT NULL,
  share_type_id TEXT NOT NULL,
  availability_zone TEXT NOT NULL,
  status TEXT NOT NULL,
  export_locations TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS manila_snapshots (
  id TEXT PRIMARY KEY,
  share_id TEXT NOT NULL,
  project_id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  size_gib BIGINT NOT NULL,
  status TEXT NOT NULL,
  created_at TEXT NOT NULL
);
`);

        exec(`
INSERT INTO manila_share_types(id, name, description, protocol, driver_handles_share_servers, snapshot_support)
VALUES
  ('gold', 'gold', 'High throughput NFS-backed tier', 'NFS', true, true),
  ('silver', 'silver', 'General purpose CIFS-backed tier', 'CIFS', false, true),
  ('cephfs-premium', 'cephfs-premium', 'CephFS tier for container workloads', 'CEPHFS', true, true)
ON CONFLICT (id) DO NOTHING;
`);
    }
}
