module uim.infrastructure.infobox.application.usecases.get_project;

import uim.infrastructure.infobox.application.dto.commands : GetProjectQuery;
import uim.infrastructure.infobox.domain.entities.project : Project;
import uim.infrastructure.infobox.domain.ports.repositories.project : IProjectRepository;

class GetProjectUseCase {
    private IProjectRepository repository;

    this(IProjectRepository repository) {
        this.repository = repository;
    }

    Project execute(in GetProjectQuery query) {
        if (query.id.length == 0) {
            throw new Exception("project id must not be empty");
        }

        auto result = repository.findById(query.id);
        if (result is null) {
            throw new Exception("project not found: " ~ query.id);
        }
        return *result;
    }
}
