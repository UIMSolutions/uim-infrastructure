module uim.infrastructure.kafka.application.usecases.delete_consumer_group;

import uim.infrastructure.kafka.domain.ports.repositories.consumer_group : IConsumerGroupRepository;

class DeleteConsumerGroupUseCase {
    private IConsumerGroupRepository repo;

    this(IConsumerGroupRepository repo) {
        this.repo = repo;
    }

    bool execute(string groupId) {
        auto existing = repo.findByGroupId(groupId);
        if (existing is null) return false;
        repo.deleteByGroupId(groupId);
        return true;
    }
}
