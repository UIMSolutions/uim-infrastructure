module uim.infrastructure.infobox.application.usecases.get_job;

import uim.infrastructure.infobox.application.dto.commands : GetJobQuery;
import uim.infrastructure.infobox.domain.entities.job : Job;
import uim.infrastructure.infobox.domain.ports.repositories.job : IJobRepository;

class GetJobUseCase {
    private IJobRepository repository;

    this(IJobRepository repository) {
        this.repository = repository;
    }

    Job execute(in GetJobQuery query) {
        if (query.id.length == 0) {
            throw new Exception("job id must not be empty");
        }

        auto result = repository.findById(query.id);
        if (result is null) {
            throw new Exception("job not found: " ~ query.id);
        }
        return *result;
    }
}
