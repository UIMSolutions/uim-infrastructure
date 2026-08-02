module uim.infrastructure.hts_service.application.usecases.list_dataset_records;

import uim.infrastructure.hts_service.domain.entities.hts_record : HtsRecord;
import uim.infrastructure.hts_service.domain.ports.repositories.sequencing_repository :
    ISequencingRepository;

class ListDatasetRecordsUseCase {
    private ISequencingRepository repository;

    this(ISequencingRepository repository) {
        this.repository = repository;
    }

    HtsRecord[] execute(string datasetId) {
        if (datasetId.length == 0) {
            throw new Exception("datasetId is required");
        }

        return repository.listByDataset(datasetId);
    }
}
