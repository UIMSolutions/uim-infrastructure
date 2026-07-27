/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.application.dtos.broker;

struct RegisterBrokerDTO {
    uint id;
    string host;
    ushort port;
    string rack;
}

struct UpdateBrokerDTO {
    string status;
}

struct BrokerResponseDTO {
    uint id;
    string host;
    ushort port;
    string status;
    string rack;
    string startedAt;
}
