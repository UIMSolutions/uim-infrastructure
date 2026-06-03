module uim.infrastructure.manila.infrastructure.persistence.postgresql.snapshot_repository;

import std.conv : to;
import std.datetime : SysTime;
import uim.infrastructure.manila.domain.entities.share_snapshot : ShareSnapshot, snapshotStatusFromString, snapshotStatusToString;
import uim.infrastructure.manila.domain.ports.repositories.snapshot : ISnapshotRepository;
import uim.infrastructure.manila.infrastructure.persistence.postgresql.sql_runner : PostgreSqlSqlRunner;

class PostgreSqlSnapshotRepository : ISnapshotRepository {
    private PostgreSqlSqlRunner sql;

    this(string dsn) {
        sql = new PostgreSqlSqlRunner(dsn);
    }

    override void save(ShareSnapshot snapshot) {
        auto sqlText = "INSERT INTO manila_snapshots (id, share_id, project_id, name, description, size_gib, status, created_at) VALUES ('" ~
            sql.escape(snapshot.id) ~ "','" ~
            sql.escape(snapshot.shareId) ~ "','" ~
            sql.escape(snapshot.projectId) ~ "','" ~
            sql.escape(snapshot.name) ~ "','" ~
            sql.escape(snapshot.description) ~ "'," ~
            snapshot.sizeGiB.to!string ~ ",'" ~
            sql.escape(snapshotStatusToString(snapshot.status)) ~ "','" ~
            sql.escape(snapshot.createdAt.toISOExtString()) ~
            "') ON CONFLICT (id) DO UPDATE SET share_id=EXCLUDED.share_id, project_id=EXCLUDED.project_id, name=EXCLUDED.name, description=EXCLUDED.description, size_gib=EXCLUDED.size_gib, status=EXCLUDED.status, created_at=EXCLUDED.created_at;";
        sql.exec(sqlText);
    }

    override ShareSnapshot[] list() {
        return fromRows(sql.query("SELECT id, share_id, project_id, name, description, size_gib, status, created_at FROM manila_snapshots ORDER BY created_at DESC;"));
    }

    override ShareSnapshot[] listByProject(string projectId) {
        return fromRows(sql.query("SELECT id, share_id, project_id, name, description, size_gib, status, created_at FROM manila_snapshots WHERE project_id='" ~ sql.escape(projectId) ~ "' ORDER BY created_at DESC;"));
    }

    override void removeByShareId(string shareId) {
        sql.exec("DELETE FROM manila_snapshots WHERE share_id='" ~ sql.escape(shareId) ~ "';");
    }

    private ShareSnapshot[] fromRows(string[][] rows) {
        ShareSnapshot[] result;
        foreach (row; rows) {
            if (row.length < 8) {
                continue;
            }
            result ~= ShareSnapshot(
                row[0],
                row[1],
                row[2],
                row[3],
                row[4],
                to!ulong(row[5]),
                snapshotStatusFromString(row[6]),
                SysTime.fromISOExtString(row[7])
            );
        }
        return result;
    }
}
