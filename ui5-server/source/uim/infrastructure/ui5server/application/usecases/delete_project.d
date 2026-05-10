module uim.infrastructure.ui5server.application.usecases.delete_project;

import uim.infrastructure.ui5server.domain.ports.repositories.project : IProjectRepository;

class DeleteProjectUseCase {
    private IProjectRepository repo;

    this(IProjectRepository repo) {
        this.repo = repo;
    }

    bool execute(string id) {
        return repo.remove(id);
    }
}
