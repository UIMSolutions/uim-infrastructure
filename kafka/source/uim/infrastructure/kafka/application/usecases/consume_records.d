module uim.infrastructure.kafka.application.usecases.consume_records;

import uim.infrastructure.kafka.domain.entities.record : Record;
import uim.infrastructure.kafka.domain.ports.repositories.record : IRecordRepository;
import uim.infrastructure.kafka.application.dtos.record : RecordResponseDTO;

class ConsumeRecordsUseCase {
    private IRecordRepository repo;

    this(IRecordRepository repo) {
        this.repo = repo;
    }

    RecordResponseDTO[] execute(string topic, uint partition, long offset, uint maxRecords) {
        auto records = repo.fetch(topic, partition, offset, maxRecords);
        RecordResponseDTO[] results;
        foreach (r; records) {
            string[string] headers;
            foreach (h; r.headers) {
                headers[h.key] = h.value;
            }
            results ~= RecordResponseDTO(
                r.topic,
                r.partition,
                r.offset,
                r.key,
                r.value,
                r.timestamp,
                headers,
            );
        }
        return results;
    }
}
