module uim.infrastructure.kafka.infrastructure.adapters.inmemory.record_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.kafka.domain.entities.record : Record;
import uim.infrastructure.kafka.domain.ports.repositories.record : IRecordRepository;

class InMemoryRecordRepository : IRecordRepository {
    private Record[][string] partitionLogs;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    private string partitionKey(string topic, uint partition) {
        import std.conv : to;
        return topic ~ "-" ~ partition.to!string;
    }

    long append(string topic, uint partition, in Record record) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto key = partitionKey(topic, partition);
        if (key !in partitionLogs) {
            partitionLogs[key] = [];
        }
        auto offset = cast(long) partitionLogs[key].length;
        auto rec = cast(Record) record;
        rec.offset = offset;
        rec.partition = partition;
        partitionLogs[key] ~= rec;
        return offset;
    }

    Record[] fetch(string topic, uint partition, long offset, uint maxRecords) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto key = partitionKey(topic, partition);
        if (key !in partitionLogs) return [];
        auto log = partitionLogs[key];
        if (offset >= cast(long) log.length) return [];
        auto end = offset + maxRecords;
        if (end > cast(long) log.length) end = cast(long) log.length;
        return log[cast(size_t) offset .. cast(size_t) end];
    }

    long getLatestOffset(string topic, uint partition) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto key = partitionKey(topic, partition);
        if (key !in partitionLogs) return 0;
        return cast(long) partitionLogs[key].length;
    }

    long getEarliestOffset(string topic, uint partition) {
        return 0;
    }
}
