module uim.infrastructure.hts_service.infrastructure.persistence.memory.sequencing_repository;

import uim.infrastructure.hts_service.domain.entities.hts_record : HtsRecord;
import uim.infrastructure.hts_service.domain.ports.repositories.sequencing_repository :
    ISequencingRepository;
import std.algorithm.searching : canFind;

class InMemorySequencingRepository : ISequencingRepository {
    private HtsRecord[][string] datasets;

    override void replaceDataset(string datasetId, HtsRecord[] records) {
        datasets[datasetId] = records.dup;
    }

    override HtsRecord[] listByDataset(string datasetId) {
        if (auto ptr = datasetId in datasets) {
            return (*ptr).dup;
        }

        return [];
    }

    override HtsRecord[] listByReference(string datasetId, string referenceName) {
        HtsRecord[] filtered;

        if (auto ptr = datasetId in datasets) {
            foreach (record; *ptr) {
                if (record.referenceName == referenceName) {
                    filtered ~= record;
                }
            }
        }

        return filtered;
    }

    override string[] listDatasets() {
        string[] names;
        foreach (name, _; datasets) {
            names ~= name;
        }
        return names;
    }
}
