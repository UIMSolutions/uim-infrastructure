module uim.infrastructure.kafka.application.usecases.delete_topic;

import uim.infrastructure.kafka.domain.ports.repositories.topic : ITopicRepository;

class DeleteTopicUseCase {
    private ITopicRepository repo;

    this(ITopicRepository repo) {
        this.repo = repo;
    }

    bool execute(string name) {
        auto existing = repo.findByName(name);
        if (existing is null) return false;
        repo.deleteByName(name);
        return true;
    }
}
