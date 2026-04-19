module uim.infrastructure.kafka.application.usecases.list_brokers;

import std.algorithm : map;
import std.array : array;
import std.conv : to;
import uim.infrastructure.kafka.domain.entities.broker : Broker;
import uim.infrastructure.kafka.domain.ports.repositories.broker : IBrokerRepository;
import uim.infrastructure.kafka.application.dtos.broker : BrokerResponseDTO;

class ListBrokersUseCase {
    private IBrokerRepository repo;

    this(IBrokerRepository repo) {
        this.repo = repo;
    }

    BrokerResponseDTO[] execute() {
        return repo.list().map!(b => BrokerResponseDTO(
            b.id,
            b.host,
            b.port,
            b.status.to!string,
            b.rack,
            b.startedAt,
        )).array;
    }
}
