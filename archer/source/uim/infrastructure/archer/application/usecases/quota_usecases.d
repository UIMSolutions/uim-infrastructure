module uim.infrastructure.archer.application.usecases.quota_usecases;

import uim.infrastructure.archer.application.dto.commands : UpdateQuotaCommand;
import uim.infrastructure.archer.domain.entities.quota : ArcherQuota, ArcherQuotaDefaults;
import uim.infrastructure.archer.domain.ports.repositories.quota : IQuotaRepository;

class ListQuotasUseCase {
    private IQuotaRepository repository;

    this(IQuotaRepository repository) {
        this.repository = repository;
    }

    ArcherQuota[] execute(string projectId = "") {
        if (projectId.length == 0) {
            return repository.list();
        }

        ArcherQuota[] result;
        auto ptr = repository.findByProjectId(projectId);
        if (ptr !is null) {
            result ~= *ptr;
        }
        return result;
    }
}

class GetQuotaUseCase {
    private IQuotaRepository repository;
    private ArcherQuotaDefaults defaults;

    this(IQuotaRepository repository, ArcherQuotaDefaults defaults) {
        this.repository = repository;
        this.defaults = defaults;
    }

    ArcherQuota execute(string projectId) {
        auto ptr = repository.findByProjectId(projectId);
        if (ptr !is null) {
            return *ptr;
        }
        return ArcherQuota(defaults.service, defaults.endpoint, 0, 0, projectId);
    }
}

class GetQuotaDefaultsUseCase {
    private ArcherQuotaDefaults defaults;

    this(ArcherQuotaDefaults defaults) {
        this.defaults = defaults;
    }

    ArcherQuotaDefaults execute() {
        return defaults;
    }
}

class UpdateQuotaUseCase {
    private IQuotaRepository repository;
    private ArcherQuotaDefaults defaults;

    this(IQuotaRepository repository, ArcherQuotaDefaults defaults) {
        this.repository = repository;
        this.defaults = defaults;
    }

    ArcherQuota execute(in UpdateQuotaCommand cmd) {
        auto quota = ArcherQuota(
            cmd.hasService ? cmd.service : defaults.service,
            cmd.hasEndpoint ? cmd.endpoint : defaults.endpoint,
            0,
            0,
            cmd.projectId
        );
        repository.save(quota);
        return quota;
    }
}

class DeleteQuotaUseCase {
    private IQuotaRepository repository;

    this(IQuotaRepository repository) {
        this.repository = repository;
    }

    void execute(string projectId) {
        repository.remove(projectId);
    }
}
