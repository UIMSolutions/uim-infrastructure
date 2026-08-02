module uim.infrastructure.hts_service.application.dto.hts_commands;

import uim.infrastructure.hts_service.domain.entities.hts_record : HtsFormat;

struct IngestDatasetCommand {
    string datasetId;
    HtsFormat format;
    string rawContent;
}

struct ListByReferenceCommand {
    string datasetId;
    string referenceName;
}
