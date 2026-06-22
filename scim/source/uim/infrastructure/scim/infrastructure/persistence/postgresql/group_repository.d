module uim.infrastructure.scim.infrastructure.persistence.postgresql.group_repository;

import std.array : join;
import std.datetime : SysTime;
import std.string : split, toLower;
import uim.infrastructure.scim.domain.entities.group : ScimGroup;
import uim.infrastructure.scim.domain.ports.repositories.group : IGroupRepository;
import uim.infrastructure.scim.infrastructure.persistence.postgresql.sql_runner : PostgreSqlSqlRunner;

class PostgreSqlGroupRepository : IGroupRepository {
    private PostgreSqlSqlRunner sql;

    this(string dsn) {
        sql = new PostgreSqlSqlRunner(dsn);
    }

    override void save(ScimGroup group) {
        auto members = sql.escape(group.memberIds.join("|"));
        auto query = "INSERT INTO scim_groups (id, external_id, display_name, member_ids, created_at, " ~
            "last_modified_at, version_tag) VALUES ('" ~
            sql.escape(group.id) ~ "','" ~
            sql.escape(group.externalId) ~ "','" ~
            sql.escape(group.displayName) ~ "','" ~
            members ~ "','" ~
            sql.escape(group.createdAt.toISOExtString()) ~ "','" ~
            sql.escape(group.lastModifiedAt.toISOExtString()) ~ "','" ~
            sql.escape(group.versionTag) ~
            "') ON CONFLICT (id) DO UPDATE SET external_id=EXCLUDED.external_id, " ~
            "display_name=EXCLUDED.display_name, member_ids=EXCLUDED.member_ids, " ~
            "created_at=EXCLUDED.created_at, last_modified_at=EXCLUDED.last_modified_at, " ~
            "version_tag=EXCLUDED.version_tag;";
        sql.exec(query);
    }

    override ScimGroup[] list() {
        return fromRows(sql.query(
            "SELECT id, external_id, display_name, member_ids, created_at, last_modified_at, " ~
            "version_tag FROM scim_groups ORDER BY created_at DESC;"
        ));
    }

    override ScimGroup* findById(string id) {
        auto rows = fromRows(sql.query(
            "SELECT id, external_id, display_name, member_ids, created_at, last_modified_at, " ~
            "version_tag FROM scim_groups WHERE id='" ~ sql.escape(id) ~ "' LIMIT 1;"
        ));
        if (rows.length == 0) {
            return null;
        }
        return clone(rows[0]);
    }

    override ScimGroup* findByDisplayName(string displayName) {
        auto rows = fromRows(sql.query(
            "SELECT id, external_id, display_name, member_ids, created_at, last_modified_at, " ~
            "version_tag FROM scim_groups WHERE lower(display_name)='" ~
            sql.escape(toLower(displayName)) ~ "' LIMIT 1;"
        ));
        if (rows.length == 0) {
            return null;
        }
        return clone(rows[0]);
    }

    override void remove(string id) {
        sql.exec("DELETE FROM scim_groups WHERE id='" ~ sql.escape(id) ~ "';");
    }

    private ScimGroup[] fromRows(string[][] rows) {
        ScimGroup[] groups;
        foreach (row; rows) {
            if (row.length < 7) {
                continue;
            }
            auto members = row[3].length == 0 ? [] : split(row[3], "|");
            groups ~= ScimGroup(
                row[0],
                row[1],
                row[2],
                members,
                SysTime.fromISOExtString(row[4]),
                SysTime.fromISOExtString(row[5]),
                row[6]
            );
        }
        return groups;
    }

    private ScimGroup* clone(ScimGroup group) {
        return new ScimGroup(
            group.id,
            group.externalId,
            group.displayName,
            group.memberIds.dup,
            group.createdAt,
            group.lastModifiedAt,
            group.versionTag
        );
    }
}
