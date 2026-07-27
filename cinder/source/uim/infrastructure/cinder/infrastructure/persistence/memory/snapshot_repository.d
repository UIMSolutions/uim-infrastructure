/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.infrastructure.persistence.memory.snapshot_repository;

import std.datetime.systime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.cinder.domain.entities.snapshot : Snapshot, SnapshotStatus;
import uim.infrastructure.cinder.domain.ports.repositories.snapshot : ISnapshotRepository;

class InMemorySnapshotRepository : ISnapshotRepository {
    private Snapshot[] records;

    override Snapshot[] list(string projectIdFilter = "") {
        if (projectIdFilter.length == 0) {
            return records.dup;
        }

        Snapshot[] filtered;
        foreach (record; records) {
            if (record.projectId == projectIdFilter) {
                filtered ~= record;
            }
        }
        return filtered;
    }

    override Snapshot create(string projectId, string volumeId, string name, string description, ulong sizeGiB) {
        auto record = Snapshot(
            randomUUID().toString(),
            volumeId,
            projectId,
            name,
            description,
            sizeGiB,
            SnapshotStatus.available,
            Clock.currTime.toISOExtString()
        );

        records ~= record;
        return record;
    }

    override Snapshot* getById(string id) {
        foreach (ref record; records) {
            if (record.id == id) {
                return &record;
            }
        }
        return null;
    }

    override bool deleteById(string id) {
        foreach (idx, record; records) {
            if (record.id == id) {
                records = records[0 .. idx] ~ records[idx + 1 .. $];
                return true;
            }
        }
        return false;
    }
}
