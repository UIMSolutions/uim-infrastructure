module uim.infrastructure.infobox.application.usecases.delete_project;

import uim.infrastructure.infobox.domain.ports.repositories.project : IProjectRepository;

class DeleteProjectUseCase {
    private IProjectRepository repository;

    this(IProjectRepository repository) {
        this.repository = repository;
    }

    void execute(string projectId) {
        if (projectId.length == 0) {
            throw new Exception("project id must not be empty");
        }

        auto existing = repository.findById(projectId);
        if (existing is null) {
            throw new Exception("project not found: " ~ projectId);
        }

        repository.deleteById(projectId);
    }
}
