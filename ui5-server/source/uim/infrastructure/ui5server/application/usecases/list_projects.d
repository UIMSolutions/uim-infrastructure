module uim.infrastructure.ui5server.application.usecases.list_projects;

import uim.infrastructure.ui5server.domain.ports.repositories.project : IProjectRepository;
import uim.infrastructure.ui5server.application.dtos.project : ProjectResponseDTO, DependencyDTO;

class ListProjectsUseCase {
    private IProjectRepository repo;

    this(IProjectRepository repo) {
        this.repo = repo;
    }

    ProjectResponseDTO[] execute() {
        import std.conv : to;
        ProjectResponseDTO[] results;
        foreach (p; repo.findAll()) {
            DependencyDTO[] deps;
            foreach (d; p.dependencies) {
                deps ~= DependencyDTO(d.name, d.version_);
            }
            results ~= ProjectResponseDTO(
                p.id,
                p.name,
                p.type.to!string,
                p.rootPath,
                p.version_,
                p.namespace_,
                deps,
            );
        }
        return results;
    }
}
