/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.application.dtos.record;

struct ProduceRecordDTO {
    string topic;
    string key;
    string value;
    string[string] headers;
}

struct RecordResponseDTO {
    string topic;
    uint partition;
    long offset;
    string key;
    string value;
    long timestamp;
    string[string] headers;
}
