/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.domain.ports.repositories.broker;

import uim.infrastructure.kafka.domain.entities.broker : Broker;

interface IBrokerRepository {
    void save(in Broker broker);
    void update(in Broker broker);
    Broker[] list();
    Broker* findById(uint id);
    void deleteById(uint id);
}
