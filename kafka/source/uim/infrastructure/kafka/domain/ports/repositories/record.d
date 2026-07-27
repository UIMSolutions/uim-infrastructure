/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.domain.ports.repositories.record;

import uim.infrastructure.kafka.domain.entities.record : Record;

interface IRecordRepository {
    long append(string topic, uint partition, in Record record);
    Record[] fetch(string topic, uint partition, long offset, uint maxRecords);
    long getLatestOffset(string topic, uint partition);
    long getEarliestOffset(string topic, uint partition);
}
