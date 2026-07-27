/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
