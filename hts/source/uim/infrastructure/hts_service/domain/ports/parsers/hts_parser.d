module uim.infrastructure.hts_service.domain.ports.parsers.hts_parser;

import uim.infrastructure.hts_service.domain.entities.hts_record : HtsFormat,
    HtsRecord;

interface IHtsParser {
    HtsRecord[] parse(string datasetId, HtsFormat format, string rawContent);
}
