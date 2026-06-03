module uim.infrastructure.manila.infrastructure.persistence.postgresql.share_type_repository;

import uim.infrastructure.manila.domain.entities.share_type : ShareProtocol, ShareType, shareProtocolFromString;
import uim.infrastructure.manila.domain.ports.repositories.share_type : IShareTypeRepository;
import uim.infrastructure.manila.infrastructure.persistence.postgresql.sql_runner : PostgreSqlSqlRunner;

class PostgreSqlShareTypeRepository : IShareTypeRepository {
    private PostgreSqlSqlRunner sql;

    this(string dsn) {
        sql = new PostgreSqlSqlRunner(dsn);
    }

    override ShareType[] list() {
        auto rows = sql.query("SELECT id, name, description, protocol, driver_handles_share_servers, snapshot_support FROM manila_share_types ORDER BY id;");
        ShareType[] result;
        foreach (row; rows) {
            if (row.length < 6) {
                continue;
            }
            result ~= ShareType(
                row[0],
                row[1],
                row[2],
                shareProtocolFromString(row[3]),
                row[4] == "t" || row[4] == "true",
                row[5] == "t" || row[5] == "true"
            );
        }
        return result;
    }

    override ShareType* findById(string id) {
        auto rows = sql.query("SELECT id, name, description, protocol, driver_handles_share_servers, snapshot_support FROM manila_share_types WHERE id='" ~ sql.escape(id) ~ "' LIMIT 1;");
        if (rows.length == 0 || rows[0].length < 6) {
            return null;
        }

        auto row = rows[0];
        return new ShareType(
            row[0],
            row[1],
            row[2],
            shareProtocolFromString(row[3]),
            row[4] == "t" || row[4] == "true",
            row[5] == "t" || row[5] == "true"
        );
    }
}
