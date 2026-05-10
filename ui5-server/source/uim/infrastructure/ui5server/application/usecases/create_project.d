module uim.infrastructure.ui5server.application.usecases.create_project;

import uim.infrastructure.ui5server.domain.ports.repositories.project : IProjectRepository;
import uim.infrastructure.ui5server.domain.entities.project : Project, ProjectType, Dependency;
import uim.infrastructure.ui5server.application.dtos.project : CreateProjectDTO, ProjectResponseDTO, DependencyDTO;

class CreateProjectUseCase {
    private IProjectRepository repo;

    this(IProjectRepository repo) {
        this.repo = repo;
    }

    ProjectResponseDTO execute(CreateProjectDTO dto) {
        import std.conv : to;
        import std.uuid : randomUUID;

        Dependency[] deps;
        foreach (d; dto.dependencies) {
            deps ~= Dependency(d.name, d.version_);
        }

        auto project = Project(
            randomUUID().toString(),
            dto.name,
            dto.type.to!ProjectType,
            dto.rootPath,
            dto.version_,
            dto.namespace_,
            deps,
        );

        repo.save(project);

        DependencyDTO[] dtosDeps;
        foreach (d; project.dependencies) {
            dtosDeps ~= DependencyDTO(d.name, d.version_);
        }

        return ProjectResponseDTO(
            project.id,
            project.name,
            project.type.to!string,
            project.rootPath,
            project.version_,
            project.namespace_,
            dtosDeps,
        );
    }
}
