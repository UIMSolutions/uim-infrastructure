module uim.infrastructure.hts_service.application.usecases.ingest_dataset;

import uim.infrastructure.hts_service.application.dto.hts_commands :
    IngestDatasetCommand;
import uim.infrastructure.hts_service.domain.entities.hts_record : IngestSummary;
import uim.infrastructure.hts_service.domain.ports.parsers.hts_parser : IHtsParser;
import uim.infrastructure.hts_service.domain.ports.repositories.sequencing_repository :
    ISequencingRepository;

class IngestDatasetUseCase {
    private ISequencingRepository repository;
    private IHtsParser parser;

    this(ISequencingRepository repository, IHtsParser parser) {
        this.repository = repository;
        this.parser = parser;
    }

    IngestSummary execute(IngestDatasetCommand command) {
        if (command.datasetId.length == 0) {
            throw new Exception("datasetId is required");
        }
        if (command.rawContent.length == 0) {
            throw new Exception("rawContent is required");
        }

        auto records = parser.parse(command.datasetId, command.format, command.rawContent);
        repository.replaceDataset(command.datasetId, records);

        return IngestSummary(command.datasetId, command.format, records.length);
    }
}
