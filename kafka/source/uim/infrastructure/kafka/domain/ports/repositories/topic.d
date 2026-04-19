module uim.infrastructure.kafka.domain.ports.repositories.topic;

import uim.infrastructure.kafka.domain.entities.topic : Topic;
import uim.infrastructure.kafka.domain.entities.partition : PartitionInfo;

interface ITopicRepository {
    void save(in Topic topic);
    void update(in Topic topic);
    Topic[] list();
    Topic* findByName(string name);
    void deleteByName(string name);
    PartitionInfo[] getPartitions(string topicName);
}
