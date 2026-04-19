module uim.infrastructure.kafka.infrastructure.adapters.inmemory.consumer_group_repository;

import core.sync.mutex : Mutex;
import std.conv : to;
import uim.infrastructure.kafka.domain.entities.consumer_group : ConsumerGroup, ConsumerOffset;
import uim.infrastructure.kafka.domain.ports.repositories.consumer_group : IConsumerGroupRepository;

class InMemoryConsumerGroupRepository : IConsumerGroupRepository {
    private ConsumerGroup[string] groups;
    private long[string] committedOffsets;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    private string offsetKey(string groupId, string topic, uint partition) {
        return groupId ~ "|" ~ topic ~ "|" ~ partition.to!string;
    }

    void save(in ConsumerGroup group) {
        mtx.lock();
        scope(exit) mtx.unlock();
        groups[group.groupId] = cast(ConsumerGroup) group;
    }

    void update(in ConsumerGroup group) {
        mtx.lock();
        scope(exit) mtx.unlock();
        groups[group.groupId] = cast(ConsumerGroup) group;
    }

    ConsumerGroup[] list() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return groups.values;
    }

    ConsumerGroup* findByGroupId(string groupId) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = groupId in groups;
        if (p is null) return null;
        return p;
    }

    void deleteByGroupId(string groupId) {
        mtx.lock();
        scope(exit) mtx.unlock();
        groups.remove(groupId);
    }

    void commitOffset(string groupId, string topic, uint partition, long offset) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto key = offsetKey(groupId, topic, partition);
        committedOffsets[key] = offset;
    }

    ConsumerOffset[] getOffsets(string groupId, string topic) {
        mtx.lock();
        scope(exit) mtx.unlock();
        ConsumerOffset[] results;
        foreach (k, v; committedOffsets) {
            import std.string : startsWith;
            auto prefix = groupId ~ "|" ~ topic ~ "|";
            if (k.startsWith(prefix)) {
                auto partStr = k[prefix.length .. $];
                auto part = partStr.to!uint;
                results ~= ConsumerOffset(groupId, topic, part, v, v, 0);
            }
        }
        return results;
    }
}
