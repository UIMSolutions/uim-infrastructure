module uim.infrastructure.infobox.application.usecases.list_builds;

import uim.infrastructure.infobox.application.dto.commands : ListBuildsQuery;
import uim.infrastructure.infobox.domain.entities.build : Build;
import uim.infrastructure.infobox.domain.ports.repositories.build : IBuildRepository;

class ListBuildsUseCase {
    private IBuildRepository repository;

    this(IBuildRepository repository) {
        this.repository = repository;
    }

    Build[] execute(in ListBuildsQuery query) {
        if (query.projectId.length == 0) {
            throw new Exception("project id must not be empty");
        }
        return repository.listByProject(query.projectId);
    }
}
