module uim.infrastructure.infobox.application.usecases.list_projects;

import uim.infrastructure.infobox.domain.entities.project : Project;
import uim.infrastructure.infobox.domain.ports.repositories.project : IProjectRepository;

class ListProjectsUseCase {
    private IProjectRepository repository;

    this(IProjectRepository repository) {
        this.repository = repository;
    }

    Project[] execute() {
        return repository.list();
    }
}
