module uim.infrastructure.hts_service.domain.ports.repositories.sequencing_repository;

import uim.infrastructure.hts_service.domain.entities.hts_record : HtsRecord;

interface ISequencingRepository {
    void replaceDataset(string datasetId, HtsRecord[] records);
    HtsRecord[] listByDataset(string datasetId);
    HtsRecord[] listByReference(string datasetId, string referenceName);
    string[] listDatasets();
}
