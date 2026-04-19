module uim.infrastructure.kafka.infrastructure.adapters.inmemory.topic_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.kafka.domain.entities.topic : Topic;
import uim.infrastructure.kafka.domain.entities.partition : PartitionInfo;
import uim.infrastructure.kafka.domain.ports.repositories.topic : ITopicRepository;

class InMemoryTopicRepository : ITopicRepository {
    private Topic[string] topics;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    void save(in Topic topic) {
        mtx.lock();
        scope(exit) mtx.unlock();
        topics[topic.name] = cast(Topic) topic;
    }

    void update(in Topic topic) {
        mtx.lock();
        scope(exit) mtx.unlock();
        topics[topic.name] = cast(Topic) topic;
    }

    Topic[] list() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return topics.values;
    }

    Topic* findByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = name in topics;
        if (p is null) return null;
        return p;
    }

    void deleteByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        topics.remove(name);
    }

    PartitionInfo[] getPartitions(string topicName) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = topicName in topics;
        if (p is null) return [];
        PartitionInfo[] parts;
        foreach (i; 0 .. p.config.numPartitions) {
            parts ~= PartitionInfo(topicName, i, 0, 0, 0);
        }
        return parts;
    }
}
