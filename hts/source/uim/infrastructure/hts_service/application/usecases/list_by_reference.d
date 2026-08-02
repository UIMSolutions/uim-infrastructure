module uim.infrastructure.hts_service.application.usecases.list_by_reference;

import uim.infrastructure.hts_service.application.dto.hts_commands :
    ListByReferenceCommand;
import uim.infrastructure.hts_service.domain.entities.hts_record : HtsRecord;
import uim.infrastructure.hts_service.domain.ports.repositories.sequencing_repository :
    ISequencingRepository;

class ListByReferenceUseCase {
    private ISequencingRepository repository;

    this(ISequencingRepository repository) {
        this.repository = repository;
    }

    HtsRecord[] execute(ListByReferenceCommand command) {
        if (command.datasetId.length == 0) {
            throw new Exception("datasetId is required");
        }
        if (command.referenceName.length == 0) {
            throw new Exception("referenceName is required");
        }

        return repository.listByReference(command.datasetId, command.referenceName);
    }
}
