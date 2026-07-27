/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.infrastructure.persistence.postgresql.user_repository;

import std.array : join;
import std.conv : to;
import std.datetime : SysTime;
import std.string : split, toLower;
import uim.infrastructure.scim.domain.entities.user : ScimUser;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;
import uim.infrastructure.scim.infrastructure.persistence.postgresql.sql_runner : PostgreSqlSqlRunner;

class PostgreSqlUserRepository : IUserRepository {
    private PostgreSqlSqlRunner sql;

    this(string dsn) {
        sql = new PostgreSqlSqlRunner(dsn);
    }

    override void save(ScimUser user) {
        auto emails = sql.escape(user.emails.join("|"));
        auto query = "INSERT INTO scim_users (id, external_id, user_name, display_name, given_name, " ~
            "family_name, emails, created_at, last_modified_at, version_tag) VALUES ('" ~
            sql.escape(user.id) ~ "','" ~
            sql.escape(user.externalId) ~ "','" ~
            sql.escape(user.userName) ~ "','" ~
            sql.escape(user.displayName) ~ "','" ~
            sql.escape(user.givenName) ~ "','" ~
            sql.escape(user.familyName) ~ "','" ~
            emails ~ "','" ~
            sql.escape(user.createdAt.toISOExtString()) ~ "','" ~
            sql.escape(user.lastModifiedAt.toISOExtString()) ~ "','" ~
            sql.escape(user.versionTag) ~
            "') ON CONFLICT (id) DO UPDATE SET " ~
            "external_id=EXCLUDED.external_id, user_name=EXCLUDED.user_name, " ~
            "display_name=EXCLUDED.display_name, given_name=EXCLUDED.given_name, " ~
            "family_name=EXCLUDED.family_name, emails=EXCLUDED.emails, created_at=EXCLUDED.created_at, " ~
            "last_modified_at=EXCLUDED.last_modified_at, version_tag=EXCLUDED.version_tag;";
        sql.exec(query);
    }

    override ScimUser[] list() {
        return fromRows(sql.query(
            "SELECT id, external_id, user_name, display_name, given_name, family_name, emails, " ~
            "created_at, last_modified_at, version_tag FROM scim_users ORDER BY created_at DESC;"
        ));
    }

    override ScimUser* findById(string id) {
        auto rows = fromRows(sql.query(
            "SELECT id, external_id, user_name, display_name, given_name, family_name, emails, " ~
            "created_at, last_modified_at, version_tag FROM scim_users WHERE id='" ~ sql.escape(id) ~ "' LIMIT 1;"
        ));
        if (rows.length == 0) {
            return null;
        }
        return clone(rows[0]);
    }

    override ScimUser* findByUserName(string userName) {
        auto rows = fromRows(sql.query(
            "SELECT id, external_id, user_name, display_name, given_name, family_name, emails, " ~
            "created_at, last_modified_at, version_tag FROM scim_users WHERE lower(user_name)='" ~
            sql.escape(toLower(userName)) ~ "' LIMIT 1;"
        ));
        if (rows.length == 0) {
            return null;
        }
        return clone(rows[0]);
    }

    override void remove(string id) {
        sql.exec("DELETE FROM scim_users WHERE id='" ~ sql.escape(id) ~ "';");
    }

    private ScimUser[] fromRows(string[][] rows) {
        ScimUser[] users;
        foreach (row; rows) {
            if (row.length < 10) {
                continue;
            }

            auto emails = row[6].length == 0 ? [] : split(row[6], "|");
            users ~= ScimUser(
                row[0],
                row[1],
                row[2],
                row[3],
                row[4],
                row[5],
                emails,
                SysTime.fromISOExtString(row[7]),
                SysTime.fromISOExtString(row[8]),
                row[9]
            );
        }
        return users;
    }

    private ScimUser* clone(ScimUser user) {
        return new ScimUser(
            user.id,
            user.externalId,
            user.userName,
            user.displayName,
            user.givenName,
            user.familyName,
            user.emails.dup,
            user.createdAt,
            user.lastModifiedAt,
            user.versionTag
        );
    }
}
