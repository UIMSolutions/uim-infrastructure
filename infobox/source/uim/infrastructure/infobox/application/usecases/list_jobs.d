module uim.infrastructure.infobox.application.usecases.list_jobs;

import uim.infrastructure.infobox.application.dto.commands : ListJobsQuery;
import uim.infrastructure.infobox.domain.entities.job : Job;
import uim.infrastructure.infobox.domain.ports.repositories.job : IJobRepository;

class ListJobsUseCase {
    private IJobRepository repository;

    this(IJobRepository repository) {
        this.repository = repository;
    }

    Job[] execute(in ListJobsQuery query) {
        if (query.buildId.length == 0) {
            throw new Exception("build id must not be empty");
        }
        return repository.listByBuild(query.buildId);
    }
}
