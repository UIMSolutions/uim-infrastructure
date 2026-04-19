module uim.infrastructure.kafka.domain.ports.repositories.broker;

import uim.infrastructure.kafka.domain.entities.broker : Broker;

interface IBrokerRepository {
    void save(in Broker broker);
    void update(in Broker broker);
    Broker[] list();
    Broker* findById(uint id);
    void deleteById(uint id);
}
