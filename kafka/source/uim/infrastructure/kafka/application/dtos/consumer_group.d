/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.application.dtos.consumer_group;

struct CreateConsumerGroupDTO {
    string groupId;
}

struct ConsumerGroupResponseDTO {
    string groupId;
    string state;
    uint memberCount;
    string createdAt;
}

struct CommitOffsetDTO {
    string groupId;
    string topic;
    uint partition;
    long offset;
}

struct ConsumerOffsetResponseDTO {
    string groupId;
    string topic;
    uint partition;
    long committedOffset;
    long logEndOffset;
    long lag;
}
