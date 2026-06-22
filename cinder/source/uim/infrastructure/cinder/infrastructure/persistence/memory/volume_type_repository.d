module uim.infrastructure.cinder.infrastructure.persistence.memory.volume_type_repository;

import uim.infrastructure.cinder.domain.entities.volume_type : VolumeType;
import uim.infrastructure.cinder.domain.ports.repositories.volume_type : IVolumeTypeRepository;

class InMemoryVolumeTypeRepository : IVolumeTypeRepository {
    private VolumeType[] records;

    this() {
        records ~= VolumeType("fast-ssd", "fast-ssd", "High performance SSD-backed volume type", true);
        records ~= VolumeType("general-hdd", "general-hdd", "General purpose HDD-backed volume type", true);
        records ~= VolumeType("encrypted-premium", "encrypted-premium", "Encrypted premium tier", true);
    }

    override VolumeType[] list() {
        return records.dup;
    }

    override VolumeType* getById(string id) {
        foreach (ref record; records) {
            if (record.id == id) {
                return &record;
            }
        }
        return null;
    }
}
