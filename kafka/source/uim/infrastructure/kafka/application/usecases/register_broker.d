module uim.infrastructure.kafka.application.usecases.register_broker;

import std.conv : to;
import uim.infrastructure.kafka.domain.entities.broker;
import uim.infrastructure.kafka.domain.ports.repositories.broker : IBrokerRepository;
import uim.infrastructure.kafka.application.dtos.broker;

class RegisterBrokerUseCase {
    private IBrokerRepository repo;

    this(IBrokerRepository repo) {
        this.repo = repo;
    }

    BrokerResponseDTO execute(in RegisterBrokerDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing !is null) {
            throw new Exception("Broker " ~ dto.id.to!string ~ " already registered");
        }

        auto broker = Broker(
            dto.id,
            dto.host,
            dto.port,
            BrokerStatus.active,
            dto.rack,
            "2026-04-19T00:00:00Z",
        );

        repo.save(broker);

        return BrokerResponseDTO(
            broker.id,
            broker.host,
            broker.port,
            broker.status.to!string,
            broker.rack,
            broker.startedAt,
        );
    }
}
