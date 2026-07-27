/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.manila.infrastructure.persistence.postgresql.share_repository;

import std.conv : to;
import std.datetime : SysTime;
import std.array : join;
import std.string : split;
import uim.infrastructure.manila.domain.entities.share : Share, shareStatusFromString, shareStatusToString;
import uim.infrastructure.manila.domain.entities.share_type : shareProtocolFromString, shareProtocolToString;
import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;
import uim.infrastructure.manila.infrastructure.persistence.postgresql.sql_runner : PostgreSqlSqlRunner;

class PostgreSqlShareRepository : IShareRepository {
    private PostgreSqlSqlRunner sql;

    this(string dsn) {
        sql = new PostgreSqlSqlRunner(dsn);
    }

    override void save(Share share) {
        auto exportLocations = sql.escape(share.exportLocations.join("|"));
        auto sqlText = "INSERT INTO manila_shares (id, project_id, name, description, size_gib, protocol, share_type_id, availability_zone, status, export_locations, created_at) VALUES ('" ~
            sql.escape(share.id) ~ "','" ~
            sql.escape(share.projectId) ~ "','" ~
            sql.escape(share.name) ~ "','" ~
            sql.escape(share.description) ~ "'," ~
            share.sizeGiB.to!string ~ ",'" ~
            sql.escape(shareProtocolToString(share.protocol)) ~ "','" ~
            sql.escape(share.shareTypeId) ~ "','" ~
            sql.escape(share.availabilityZone) ~ "','" ~
            sql.escape(shareStatusToString(share.status)) ~ "','" ~
            exportLocations ~ "','" ~
            sql.escape(share.createdAt.toISOExtString()) ~
            "') ON CONFLICT (id) DO UPDATE SET project_id=EXCLUDED.project_id, name=EXCLUDED.name, description=EXCLUDED.description, size_gib=EXCLUDED.size_gib, protocol=EXCLUDED.protocol, share_type_id=EXCLUDED.share_type_id, availability_zone=EXCLUDED.availability_zone, status=EXCLUDED.status, export_locations=EXCLUDED.export_locations, created_at=EXCLUDED.created_at;";
        sql.exec(sqlText);
    }

    override Share[] list() {
        return fromRows(sql.query("SELECT id, project_id, name, description, size_gib, protocol, share_type_id, availability_zone, status, export_locations, created_at FROM manila_shares ORDER BY created_at DESC;"));
    }

    override Share[] listByProject(string projectId) {
        return fromRows(sql.query("SELECT id, project_id, name, description, size_gib, protocol, share_type_id, availability_zone, status, export_locations, created_at FROM manila_shares WHERE project_id='" ~ sql.escape(projectId) ~ "' ORDER BY created_at DESC;"));
    }

    override Share* findById(string id) {
        auto rows = fromRows(sql.query("SELECT id, project_id, name, description, size_gib, protocol, share_type_id, availability_zone, status, export_locations, created_at FROM manila_shares WHERE id='" ~ sql.escape(id) ~ "' LIMIT 1;"));
        if (rows.length == 0) {
            return null;
        }
        return new Share(
            rows[0].id,
            rows[0].projectId,
            rows[0].name,
            rows[0].description,
            rows[0].sizeGiB,
            rows[0].protocol,
            rows[0].shareTypeId,
            rows[0].availabilityZone,
            rows[0].status,
            rows[0].exportLocations.dup,
            rows[0].createdAt
        );
    }

    override void remove(string id) {
        sql.exec("DELETE FROM manila_shares WHERE id='" ~ sql.escape(id) ~ "';");
    }

    private Share[] fromRows(string[][] rows) {
        Share[] result;
        foreach (row; rows) {
            if (row.length < 11) {
                continue;
            }
            auto exportLocations = row[9].length == 0 ? [] : split(row[9], "|");
            result ~= Share(
                row[0],
                row[1],
                row[2],
                row[3],
                to!ulong(row[4]),
                shareProtocolFromString(row[5]),
                row[6],
                row[7],
                shareStatusFromString(row[8]),
                exportLocations,
                SysTime.fromISOExtString(row[10])
            );
        }
        return result;
    }
}
