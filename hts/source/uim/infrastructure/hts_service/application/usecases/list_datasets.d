module uim.infrastructure.hts_service.application.usecases.list_datasets;

import uim.infrastructure.hts_service.domain.ports.repositories.sequencing_repository :
    ISequencingRepository;

class ListDatasetsUseCase {
    private ISequencingRepository repository;

    this(ISequencingRepository repository) {
        this.repository = repository;
    }

    string[] execute() {
        return repository.listDatasets();
    }
}
