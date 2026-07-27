/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.infrastructure.persistence.memory.volume_repository;

import std.datetime.systime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.cinder.domain.entities.volume : Volume, VolumeStatus;
import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class InMemoryVolumeRepository : IVolumeRepository {
    private Volume[] records;

    override Volume[] list(string projectIdFilter = "") {
        if (projectIdFilter.length == 0) {
            return records.dup;
        }

        Volume[] filtered;
        foreach (record; records) {
            if (record.projectId == projectIdFilter) {
                filtered ~= record;
            }
        }
        return filtered;
    }

    override Volume create(
        string projectId,
        string name,
        string description,
        ulong sizeGiB,
        string volumeTypeId,
        string availabilityZone
    ) {
        auto record = Volume(
            randomUUID().toString(),
            projectId,
            name,
            description,
            sizeGiB,
            volumeTypeId,
            availabilityZone,
            VolumeStatus.available,
            [],
            Clock.currTime.toISOExtString()
        );

        records ~= record;
        return record;
    }

    override Volume* getById(string id) {
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

    override bool attachById(string id, string attachmentRef) {
        auto record = getById(id);
        if (record is null) {
            return false;
        }
        record.attachments ~= attachmentRef;
        record.status = VolumeStatus.in_use;
        return true;
    }

    override bool detachById(string id, string attachmentRef) {
        auto record = getById(id);
        if (record is null) {
            return false;
        }

        foreach (idx, existing; record.attachments) {
            if (existing == attachmentRef) {
                record.attachments = record.attachments[0 .. idx] ~ record.attachments[idx + 1 .. $];
                if (record.attachments.length == 0) {
                    record.status = VolumeStatus.available;
                }
                return true;
            }
        }
        return false;
    }
}
