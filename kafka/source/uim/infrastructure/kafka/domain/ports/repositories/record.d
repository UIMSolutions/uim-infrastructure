module uim.infrastructure.kafka.domain.ports.repositories.record;

import uim.infrastructure.kafka.domain.entities.record : Record;

interface IRecordRepository {
    long append(string topic, uint partition, in Record record);
    Record[] fetch(string topic, uint partition, long offset, uint maxRecords);
    long getLatestOffset(string topic, uint partition);
    long getEarliestOffset(string topic, uint partition);
}
