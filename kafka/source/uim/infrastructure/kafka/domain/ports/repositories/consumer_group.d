/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.domain.ports.repositories.consumer_group;

import uim.infrastructure.kafka.domain.entities.consumer_group : ConsumerGroup, ConsumerOffset;

interface IConsumerGroupRepository {
    void save(in ConsumerGroup group);
    void update(in ConsumerGroup group);
    ConsumerGroup[] list();
    ConsumerGroup* findByGroupId(string groupId);
    void deleteByGroupId(string groupId);
    void commitOffset(string groupId, string topic, uint partition, long offset);
    ConsumerOffset[] getOffsets(string groupId, string topic);
}
